/**
 * Her saat başı çalışır: 24 saatten fazla uygulama açmamış ve FCM token'ı olan
 * kullanıcılara "Seni özledik, devam et!" bildirimi gönderir.
 */
const pool = require("../config/db");
const admin = require("../config/firebase");

const INTERVAL_MS = 60 * 60 * 1000; // 1 saat
const INACTIVITY_HOURS = 24;

async function run() {
  try {
    const cutoffDate = new Date(Date.now() - INACTIVITY_HOURS * 60 * 60 * 1000);
    const result = await pool.query(
      `SELECT id, fcm_token, last_activity_at, last_reminder_sent_at
       FROM users
       WHERE fcm_token IS NOT NULL
         AND TRIM(fcm_token) != ''
         AND last_activity_at IS NOT NULL
         AND last_activity_at < $1
         AND (last_reminder_sent_at IS NULL OR last_reminder_sent_at < last_activity_at)`,
      [cutoffDate]
    );

    for (const row of result.rows) {
      try {
        await admin.messaging().send({
          token: row.fcm_token,
          notification: {
            title: "Lingola",
            body: "Seni özledik! Bugün biraz pratik yapmaya ne dersin?",
          },
          android: { priority: "high" },
          apns: { payload: { aps: { contentAvailable: true } } },
        });
        await pool.query(
          `UPDATE users SET last_reminder_sent_at = NOW(), updated_at = NOW() WHERE id = $1`,
          [row.id]
        );
        console.log("[inactivityReminder] Bildirim gönderildi, user_id:", row.id);
      } catch (err) {
        if (err.code === "messaging/invalid-registration-token" || err.code === "messaging/registration-token-not-registered") {
          await pool.query(`UPDATE users SET fcm_token = NULL, updated_at = NOW() WHERE id = $1`, [row.id]);
          console.log("[inactivityReminder] Geçersiz token temizlendi, user_id:", row.id);
        } else {
          console.error("[inactivityReminder] FCM hatası user_id:", row.id, err.message);
        }
      }
    }
  } catch (err) {
    console.error("[inactivityReminder] Job hatası:", err);
  }
}

function start() {
  run();
  setInterval(run, INTERVAL_MS);
  console.log("[inactivityReminder] Her saat başı çalışacak şekilde başlatıldı.");
}

module.exports = { start, run };
