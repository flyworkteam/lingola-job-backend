const express = require("express");
const router = express.Router();
const pool = require("../config/db");
const { success, serverError } = require("../lib/response");

// GET /api/learning-tracks?language_code=english
router.get("/", async (req, res) => {
  const { language_code } = req.query;
  try {
    let result;
    if (language_code) {
      result = await pool.query(
        `SELECT id, language_code, title, description, level, sort_order
         FROM learning_tracks
         WHERE language_code = $1
         ORDER BY sort_order, id`,
        [language_code]
      );
    } else {
      result = await pool.query(
        `SELECT id, language_code, title, description, level, sort_order
         FROM learning_tracks
         ORDER BY language_code, sort_order, id`
      );
    }
    return success(res, { tracks: result.rows });
  } catch (err) {
    return serverError(res, err, "DB hatası");
  }
});

module.exports = router;

