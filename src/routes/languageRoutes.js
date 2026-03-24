const express = require("express");
const router = express.Router();
const pool = require("../config/db");
const { success, serverError } = require("../lib/response");

// GET /api/languages — tüm dilleri listele
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, code, name, native_name FROM languages ORDER BY id ASC"
    );
    return success(res, { languages: result.rows });
  } catch (err) {
    return serverError(res, err, "DB hatası");
  }
});

module.exports = router;

