// DİKKAT: Buradaki "../config/db" kısmını, MySQL bağlantını oluşturduğun
// dosyanın adına göre (örneğin "../config/mysql") güncellemelisin.
const pool = require("../config/mysqlJobDb"); 
const admin = require("../config/firebase");
const oneSignal = require("../config/onesignal");

const INTERVAL_MS = 60 * 60 * 1000; // 1 saat
const INACTIVITY_HOURS = 24;

async function run() {
  try {
    // 🎯 MySQL'de veriler array içinde array (destructuring) olarak döner: [rows]
    // 🎯 PostgreSQL'e özel olan $1 ve interval işlemleri MySQL uyumlu hale getirildi (DATE_SUB ve ?)
    const [rows] = await pool.query(
      `SELECT id, fcm_token, last_activity_at, last_reminder_sent_at
       FROM users
       WHERE fcm_token IS NOT NULL
         AND TRIM(fcm_token) != ''
         AND last_activity_at IS NOT NULL
         AND last_activity_at < DATE_SUB(NOW(), INTERVAL ? HOUR)
         AND (last_reminder_sent_at IS NULL OR last_reminder_sent_at < last_activity_at)`,
      [INACTIVITY_HOURS]
    );

    for (const row of rows) {
      try {
        if (oneSignal.isConfigured()) {
          await oneSignal.sendToSubscriptionIds(
            [row.fcm_token],
            "Lingola",
            "Seni ozledik! Bugun biraz pratik yapmaya ne dersin?"
          );
        } else {
          await admin.messaging().send({
            token: row.fcm_token,
            notification: {
              title: "Lingola",
              body: "Seni özledik! Bugün biraz pratik yapmaya ne dersin?",
            },
            android: { priority: "high" },
            apns: { payload: { aps: { contentAvailable: true } } },
          });
        }
        
        // 🎯 $1 yerine MySQL'e özel olan ? (soru işareti) kullanıldı
        await pool.query(
          `UPDATE users SET last_reminder_sent_at = NOW(), updated_at = NOW() WHERE id = ?`,
          [row.id]
        );
                console.log(
          "[inactivityReminder] Bildirim gonderildi, provider:",
          oneSignal.isConfigured() ? "onesignal" : "firebase",
          "user_id:",
          row.id
        );
      } catch (err) {
        if (
          err.code === "messaging/invalid-registration-token" ||
          err.code === "messaging/registration-token-not-registered"
        ) {
          // 🎯 $1 yerine ?
          await pool.query(`UPDATE users SET fcm_token = NULL, updated_at = NOW() WHERE id = ?`, [row.id]);
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
