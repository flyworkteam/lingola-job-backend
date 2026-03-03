// src/routes/userRoutes.js
const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const loadUser = require("../middleware/loadUser");
const pool = require("../config/db");
const { success, validationError, notFound, serverError } = require("../lib/response");
const { validate } = require("../lib/validate");

// Google'dan gelen "name" (örn. "Kadir Karatas") -> first_name, last_name
function splitDisplayName(name) {
  if (!name || typeof name !== "string") return { first_name: null, last_name: null };
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return { first_name: parts[0] || null, last_name: null };
  return {
    first_name: parts[0] || null,
    last_name: parts.slice(1).join(" ") || null,
  };
}

// Ortak: token'dan kullanıcıyı SQL'e yaz ve terminale logla
async function upsertUserAndLog(req, res) {
  const { uid, email, name } = req.user;
  const { first_name, last_name } = splitDisplayName(name || "");

  const result = await pool.query(
    `INSERT INTO users (firebase_uid, email, first_name, last_name, updated_at)
     VALUES ($1, $2, $3, $4, NOW())
     ON CONFLICT (firebase_uid) DO UPDATE SET
       email = EXCLUDED.email,
       first_name = COALESCE(EXCLUDED.first_name, users.first_name),
       last_name = COALESCE(EXCLUDED.last_name, users.last_name),
       updated_at = NOW()
     RETURNING *`,
    [uid, email || null, first_name, last_name]
  );

  const user = result.rows[0];
  console.log("--- Kullanıcı SQL'e kaydedildi / güncellendi ---");
  console.log("  id:", user.id);
  console.log("  firebase_uid:", user.firebase_uid);
  console.log("  email:", user.email);
  console.log("  first_name:", user.first_name);
  console.log("  last_name:", user.last_name);
  console.log("  updated_at:", user.updated_at);
  console.log("----------------------------------------------");

  return user;
}

// Uygulama GET /api/users/me kullanıyor (Google giriş sonrası)
router.get("/me", (req, res, next) => {
  console.log("[GET /api/users/me] İstek alındı");
  next();
}, authMiddleware, async (req, res) => {
  try {
    const user = await upsertUserAndLog(req, res);
    res.json({ success: true, data: { user }, user }); // data.user + backward compat: user
  } catch (err) {
    return serverError(res, err, "DB hatası");
  }
});

router.post("/me", authMiddleware, async (req, res) => {
  try {
    const user = await upsertUserAndLog(req, res);
    res.json({ success: true, data: { user }, user });
  } catch (err) {
    return serverError(res, err, "DB hatası");
  }
});

// Kullanıcının seçtiği learning track'i kaydet
// Body: { "learning_track_id": 7 }
router.patch("/me", authMiddleware, async (req, res) => {
  try {
    const { learning_track_id } = req.body;
    const uid = req.user?.uid;
    if (!uid) {
      return unauthorized(res);
    }

    if (learning_track_id != null) {
      const id = parseInt(learning_track_id, 10);
      if (Number.isNaN(id) || id < 1) {
        return validationError(res, "VALIDATION_ERROR", "Geçersiz learning_track_id");
      }
    }

    const result = await pool.query(
      `UPDATE users
       SET learning_track_id = $1, updated_at = NOW()
       WHERE firebase_uid = $2
       RETURNING *`,
      [learning_track_id ?? null, uid]
    );

    if (result.rows.length === 0) {
      return notFound(res, "USER_NOT_FOUND", "Kullanıcı bulunamadı");
    }

    const user = result.rows[0];
    res.json({ success: true, data: { user }, user });
  } catch (err) {
    if (err.code === "23503") {
      return validationError(res, "INVALID_TRACK", "Geçersiz learning_track_id (track bulunamadı)");
    }
    return serverError(res, err, "DB hatası");
  }
});

// GET /api/users/me/tracks — kullanıcının track bazlı ilerlemesi
router.get("/me/tracks", authMiddleware, loadUser, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT ut.id, ut.learning_track_id, ut.progress_percent, ut.completed_words_count,
              ut.started_at, ut.last_accessed_at,
              lt.title AS track_title, lt.level AS track_level
       FROM user_tracks ut
       JOIN learning_tracks lt ON lt.id = ut.learning_track_id
       WHERE ut.user_id = $1
       ORDER BY ut.last_accessed_at DESC`,
      [req.userId]
    );
    return success(res, { tracks: result.rows });
  } catch (err) {
    return serverError(res, err);
  }
});

// PATCH /api/users/me/tracks/:trackId — ilerleme güncelle (upsert)
// Body: { progress_percent?, completed_words_count? }
router.patch(
  "/me/tracks/:trackId",
  authMiddleware,
  loadUser,
  async (req, res) => {
    const trackId = parseInt(req.params.trackId, 10);
    if (Number.isNaN(trackId) || trackId < 1) {
      return validationError(res, "VALIDATION_ERROR", "Geçersiz trackId");
    }
    const { progress_percent, completed_words_count } = req.body;

    const pct = progress_percent != null ? Math.min(100, Math.max(0, parseInt(progress_percent, 10) || 0)) : null;
    const cnt = completed_words_count != null ? Math.max(0, parseInt(completed_words_count, 10) || 0) : null;

    try {
      const result = await pool.query(
        `INSERT INTO user_tracks (user_id, learning_track_id, progress_percent, completed_words_count, last_accessed_at, updated_at)
         VALUES ($1, $2, COALESCE($3, 0), COALESCE($4, 0), NOW(), NOW())
         ON CONFLICT (user_id, learning_track_id) DO UPDATE SET
           progress_percent = COALESCE($3, user_tracks.progress_percent),
           completed_words_count = COALESCE($4, user_tracks.completed_words_count),
           last_accessed_at = NOW(),
           updated_at = NOW()
         RETURNING id, user_id, learning_track_id, progress_percent, completed_words_count, started_at, last_accessed_at`,
        [req.userId, trackId, pct, cnt]
      );
      if (result.rows.length === 0) return notFound(res);
      return success(res, result.rows[0]);
    } catch (err) {
      if (err.code === "23503") {
        return validationError(res, "INVALID_TRACK", "trackId geçersiz veya mevcut değil");
      }
      return serverError(res, err);
    }
  }
);

module.exports = router;