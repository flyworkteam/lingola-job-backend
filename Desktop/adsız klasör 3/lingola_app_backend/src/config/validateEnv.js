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
}

module.exports = { validateEnv };
