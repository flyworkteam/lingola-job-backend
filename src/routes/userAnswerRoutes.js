const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const loadUser = require("../middleware/loadUser");
const pool = require("../config/db");
const { success, validationError, serverError } = require("../lib/response");
const { validate } = require("../lib/validate");

function isForeignKeyError(err) {
  return err && (err.code === "ER_NO_REFERENCED_ROW_2" || err.errno === 1452);
}

// GET /api/user-answers — giriş yapmış kullanıcının cevaplarını listele (kontrol için)
router.get("/", authMiddleware, loadUser, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, user_id, word_id, user_answer, is_correct, question_type, answered_at
       FROM user_answers
       WHERE user_id = $1
       ORDER BY answered_at DESC
       LIMIT 100`,
      [req.userId]
    );
    return success(res, { answers: result.rows });
  } catch (err) {
    return serverError(res, err);
  }
});

// POST /api/user-answers — cevap kaydet (auth + loadUser gerekli)
// Body: { word_id, user_answer?, is_correct, question_type? }
router.post(
  "/",
  authMiddleware,
  loadUser,
  validate({
    word_id: "positive_number",
    is_correct: "boolean",
  }),
  async (req, res) => {
    const { word_id, user_answer, question_type } = req.body;
    const userId = req.userId;
    const wordId = parseInt(word_id, 10);
    const isCorrect = req.body.is_correct === true || req.body.is_correct === "true";

    try {
      const insertResult = await pool.query(
        `INSERT INTO user_answers (user_id, word_id, user_answer, is_correct, question_type)
         VALUES ($1, $2, $3, $4, $5)
        `,
        [userId, wordId, user_answer ?? null, isCorrect, question_type || null]
      );
      const result = await pool.query(
        `SELECT id, user_id, word_id, user_answer, is_correct, question_type, answered_at
         FROM user_answers
         WHERE id = $1
         LIMIT 1`,
        [insertResult.insertId]
      );
      return success(res, result.rows[0], 201);
    } catch (err) {
      if (isForeignKeyError(err)) {
        return validationError(res, "INVALID_WORD", "word_id geçersiz veya mevcut değil");
      }
      return serverError(res, err);
    }
  }
);

module.exports = router;
