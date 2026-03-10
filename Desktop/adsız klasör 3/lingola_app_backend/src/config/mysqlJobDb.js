require("dotenv").config();
const mysql = require("mysql2/promise");

/**
 * Harici MySQL veritabanı (flywork1_lingolajob) için bağlantı pool'u.
 * Ortam değişkenleri:
 * - MYSQL_HOST
 * - MYSQL_PORT (opsiyonel, varsayılan 3306)
 * - MYSQL_DB
 * - MYSQL_USER
 * - MYSQL_PASSWORD
 */

const pool = mysql.createPool({
  host: process.env.MYSQL_HOST,
  port: process.env.MYSQL_PORT || 3306,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DB,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;

