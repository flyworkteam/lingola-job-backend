/**
 * Uygulama başlamadan önce zorunlu env değişkenlerini kontrol eder.
 * Eksikse process.exit(1). Test ortamında (NODE_ENV=test) atlanır.
 */
function validateEnv() {
  if (process.env.NODE_ENV === "test") return;

  const missing = [];
  if (!process.env.DATABASE_URL || process.env.DATABASE_URL.trim() === "") {
    missing.push("DATABASE_URL");
  }

  if (missing.length > 0) {
    console.error("[validateEnv] Eksik ortam değişkeni:", missing.join(", "));
    console.error("Örnek: .env dosyasında DATABASE_URL=postgresql://user:pass@localhost:5432/dbname");
    process.exit(1);
  }

  const hasOneSignalKey = Boolean(process.env.ONESIGNAL_REST_API_KEY);
  const hasOneSignalAppId = Boolean(process.env.ONESIGNAL_APP_ID);
  if (hasOneSignalKey !== hasOneSignalAppId) {
    console.warn(
      "[validateEnv] OneSignal kismi ayarlandi. ONESIGNAL_REST_API_KEY ve ONESIGNAL_APP_ID birlikte tanimli olmali."
    );
  }
}

module.exports = { validateEnv };
