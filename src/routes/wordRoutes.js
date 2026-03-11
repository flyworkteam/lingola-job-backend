const express = require("express");
const router = express.Router();
const pool = require("../config/db");
const { success, serverError, validationError } = require("../lib/response");

// GET /api/words?learning_track_id=7
router.get("/", async (req, res) => {
  const { learning_track_id } = req.query;
  try {
    let result;
    if (learning_track_id) {
      const id = parseInt(learning_track_id, 10);
      if (Number.isNaN(id) || id < 1) {
        return validationError(res, "VALIDATION_ERROR", "Geçersiz learning_track_id");
      }
      result = await pool.query(
        `SELECT id, learning_track_id, word, translation, level, sort_order
         FROM words
         WHERE learning_track_id = $1
         ORDER BY sort_order, id`,
        [id]
      );
    } else {
      result = await pool.query(
        `SELECT id, learning_track_id, word, translation, level, sort_order
         FROM words
         ORDER BY learning_track_id, sort_order, id`
      );
    }
    return success(res, { words: result.rows });
  } catch (err) {
    return serverError(res, err);
  }
});

module.exports = router;
