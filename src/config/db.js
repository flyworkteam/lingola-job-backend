require("dotenv").config();
const { Pool } = require("pg");

// DATABASE_URL yoksa veya .env okunmadıysa (injecting env 0) varsayılan kullan
const connectionString =
  process.env.DATABASE_URL ||
  "postgresql://kadirkaratas@localhost:5432/lingola_db";

if (!process.env.DATABASE_URL) {
  console.warn("[db] DATABASE_URL yok, varsayılan kullanılıyor:", connectionString.replace(/:[^:@]+@/, ":****@"));
}

const pool = new Pool({ connectionString });

module.exports = pool;
