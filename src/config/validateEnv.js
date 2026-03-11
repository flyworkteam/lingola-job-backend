/**
 * Uygulama başlamadan önce zorunlu env değişkenlerini kontrol eder.
 * Eksikse process.exit(1). Test ortamında (NODE_ENV=test) atlanır.
 */
function validateEnv() {
  if (process.env.NODE_ENV === "test") return;

  const missing = [];
  const requiredVars = [
    "MYSQL_HOST",
    "MYSQL_DB",
    "MYSQL_USER",
    "MYSQL_PASSWORD",
  ];

  for (const key of requiredVars) {
    if (!process.env[key] || process.env[key].trim() === "") {
      missing.push(key);
    }
  }

  if (missing.length > 0) {
    console.error("[validateEnv] Eksik ortam değişkeni:", missing.join(", "));
    console.error("Ornek: .env dosyasinda MYSQL_HOST, MYSQL_DB, MYSQL_USER ve MYSQL_PASSWORD tanimli olmali");
    process.exit(1);
  }
}

module.exports = { validateEnv };
