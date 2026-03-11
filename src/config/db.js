require("dotenv").config();
const mysql = require("mysql2/promise");

function mask(value) {
  if (!value) return value;
  return String(value).replace(/.(?=.{4})/g, "*");
}

function prepareQuery(sql, params = []) {
  if (!Array.isArray(params) || params.length === 0) {
    return { sql, params: [] };
  }

  const orderedParams = [];
  const convertedSql = sql.replace(/\$(\d+)/g, (_, index) => {
    orderedParams.push(params[Number(index) - 1]);
    return "?";
  });

  return { sql: convertedSql, params: orderedParams };
}

function wrapResult(resultRows, fields) {
  if (Array.isArray(resultRows)) {
    return {
      rows: resultRows,
      fields,
      rowCount: resultRows.length,
    };
  }

  return {
    rows: [],
    fields,
    rowCount: resultRows.affectedRows || 0,
    insertId: resultRows.insertId,
    affectedRows: resultRows.affectedRows,
  };
}

function createClient(connection) {
  return {
    async query(sql, params = []) {
      const statement = String(sql).trim().toUpperCase();

      if (statement === "BEGIN") {
        await connection.beginTransaction();
        return { rows: [], rowCount: 0 };
      }

      if (statement === "COMMIT") {
        await connection.commit();
        return { rows: [], rowCount: 0 };
      }

      if (statement === "ROLLBACK") {
        await connection.rollback();
        return { rows: [], rowCount: 0 };
      }

      const prepared = prepareQuery(sql, params);
      const [rows, fields] = await connection.query(prepared.sql, prepared.params);
      return wrapResult(rows, fields);
    },
    release() {
      connection.release();
    },
  };
}

const config = {
  host: process.env.MYSQL_HOST,
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DB,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};

if (!config.host || !config.user || !config.database) {
  console.warn(
    "[db] MySQL ayarlari eksik:",
    JSON.stringify({
      host: config.host || null,
      port: config.port,
      user: config.user || null,
      database: config.database || null,
      password: config.password ? mask(config.password) : null,
    })
  );
}

const pool = mysql.createPool(config);

module.exports = {
  async query(sql, params = []) {
    const prepared = prepareQuery(sql, params);
    const [rows, fields] = await pool.query(prepared.sql, prepared.params);
    return wrapResult(rows, fields);
  },
  async connect() {
    const connection = await pool.getConnection();
    return createClient(connection);
  },
  async end() {
    await pool.end();
  },
  raw: pool,
};
