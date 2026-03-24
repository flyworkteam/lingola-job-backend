// src/routes/subscriptionRoutes.js
const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const loadUser = require("../middleware/loadUser");
const pool = require("../config/db");
const { success, serverError } = require("../lib/response");

/**
 * GET /api/subscriptions/plans
 * Abonelik planlarını listele (herkes erişebilir)
 */
router.get("/plans", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, product_id, name, description, duration_days, price_cents, currency
       FROM subscription_plans
       WHERE is_active = true
       ORDER BY duration_days ASC`
    );
    return success(res, { plans: result.rows });
  } catch (err) {
    return serverError(res, err);
  }
});

/**
 * GET /api/subscriptions/me
 * Giriş yapmış kullanıcının abonelik durumu
 */
router.get("/me", authMiddleware, loadUser, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT s.id, s.plan_id, s.product_id, s.status, s.started_at, s.expires_at,
              s.cancelled_at, s.platform, sp.name AS plan_name, sp.duration_days
       FROM subscriptions s
       LEFT JOIN subscription_plans sp ON sp.id = s.plan_id
       WHERE s.user_id = $1
         AND s.status IN ('active', 'trial')
         AND (s.expires_at IS NULL OR s.expires_at > NOW())
       ORDER BY s.started_at DESC
       LIMIT 1`,
      [req.userId]
    );

    const subscription = result.rows[0] || null;
    const isPremium = !!subscription;

    return success(res, {
      subscription,
      is_premium: isPremium,
    });
  } catch (err) {
    return serverError(res, err);
  }
});

/**
 * GET /api/subscriptions/check
 * Hızlı premium kontrolü (is_premium boolean)
 */
router.get("/check", authMiddleware, loadUser, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 1 FROM subscriptions
       WHERE user_id = $1
         AND status IN ('active', 'trial')
         AND (expires_at IS NULL OR expires_at > NOW())
       LIMIT 1`,
      [req.userId]
    );
    return success(res, { is_premium: result.rows.length > 0 });
  } catch (err) {
    return serverError(res, err);
  }
});

/**
 * POST /api/subscriptions/webhook
 * RevenueCat webhook endpoint (Authorization header ile doğrulama)
 */
router.post("/webhook", async (req, res) => {
  const authHeader = process.env.REVENUECAT_AUTH_HEADER;
  if (authHeader && req.headers.authorization !== authHeader) {
    return res.status(401).send("Unauthorized");
  }

  const payload = req.body;
  if (!payload) {
    return res.status(400).json({ error: "Invalid payload" });
  }

  const event = payload.event || payload;
  const eventId = payload.id || event.id;
  const eventType = event.type || event.event_type || payload.event_type;
  const appUserId = event.app_user_id || payload.app_user_id;
  const productId = event.product_id || payload.product_id;
  const expirationAtMs = event.expiration_at_ms ?? payload.expiration_at_ms;
  const platform = event.store || payload.store || "unknown";

  // İşlemeyi arka planda yap (RevenueCat 60s timeout istediği için önce 200 dönüyoruz)
  setImmediate(async () => {
    try {
      if (!appUserId) {
        console.warn("[subscription webhook] app_user_id yok, event atlanıyor:", eventId);
        return;
      }

      // Idempotency: aynı event tekrar işlenmesin
      if (eventId) {
        const existing = await pool.query(
          "SELECT 1 FROM webhook_events WHERE id = $1",
          [String(eventId)]
        );
        if (existing.rows.length > 0) {
          console.log("[subscription webhook] Zaten işlenmiş event:", eventId);
          return;
        }
      }

      const client = await pool.connect();
      try {
        await client.query("BEGIN");

        if (eventId) {
          await client.query(
            `INSERT INTO webhook_events (id, event_type, app_user_id, payload)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (id) DO NOTHING`,
            [String(eventId), eventType || "unknown", appUserId, JSON.stringify(payload)]
          );
        }

        const userResult = await client.query(
          "SELECT id FROM users WHERE firebase_uid = $1",
          [appUserId]
        );
        if (userResult.rows.length === 0) {
          console.warn("[subscription webhook] Kullanıcı bulunamadı:", appUserId);
          await client.query("ROLLBACK");
          return;
        }
        const userId = userResult.rows[0].id;

        const expiresAt = expirationAtMs
          ? new Date(Number(expirationAtMs))
          : null;

        switch (eventType) {
          case "INITIAL_PURCHASE":
          case "RENEWAL":
          case "PRODUCT_CHANGE": {
            await client.query(
              `UPDATE subscriptions
               SET status = 'expired', updated_at = NOW()
               WHERE user_id = $1 AND status IN ('active', 'trial')`,
              [userId]
            );
            await client.query(
              `INSERT INTO subscriptions (user_id, product_id, status, started_at, expires_at, platform, updated_at)
               VALUES ($1, $2, 'active', NOW(), $3, $4, NOW())`,
              [userId, productId || "unknown", expiresAt, platform]
            );
            console.log("[subscription webhook] Abonelik aktif:", userId, productId);
            break;
          }
          case "CANCELLATION":
          case "EXPIRATION": {
            await client.query(
              `UPDATE subscriptions
               SET status = 'expired', cancelled_at = CASE WHEN $1 = 'CANCELLATION' THEN NOW() ELSE cancelled_at END,
                   expires_at = COALESCE($2, expires_at), updated_at = NOW()
               WHERE user_id = $3 AND status IN ('active', 'trial')
                 AND (expires_at IS NULL OR expires_at > NOW())`,
              [eventType, expiresAt, userId]
            );
            console.log("[subscription webhook] Abonelik sonlandı:", userId, eventType);
            break;
          }
          case "BILLING_ISSUE":
            console.log("[subscription webhook] Fatura sorunu:", userId);
            break;
          default:
            console.log("[subscription webhook] Bilinmeyen event:", eventType, eventId);
        }

        await client.query("COMMIT");
      } catch (txErr) {
        await client.query("ROLLBACK");
        throw txErr;
      } finally {
        client.release();
      }

      // Admin dashboard bildirimi (müşteri görsün)
      try {
        if (eventType === "INITIAL_PURCHASE" || eventType === "RENEWAL" || eventType === "PRODUCT_CHANGE") {
          await pool.query(
            "INSERT INTO admin_notifications (type, title, message) VALUES ($1, $2, $3)",
            ["subscription_start", "Yeni abonelik", `Kullanıcı #${userId} - ${productId || "—"}`]
          );
        } else if (eventType === "CANCELLATION" || eventType === "EXPIRATION") {
          await pool.query(
            "INSERT INTO admin_notifications (type, title, message) VALUES ($1, $2, $3)",
            ["subscription_end", "Abonelik sonlandı", `Kullanıcı #${userId}`]
          );
        } else if (eventType === "BILLING_ISSUE") {
          await pool.query(
            "INSERT INTO admin_notifications (type, title, message) VALUES ($1, $2, $3)",
            ["billing_issue", "Fatura sorunu", `Kullanıcı #${userId}`]
          );
        }
      } catch (_) {}
    } catch (err) {
        console.error("[subscription webhook] Hata:", err);
    }
  });

  res.status(200).json({ received: true });
});

module.exports = router;
