const pool = require("../config/db");
const { unauthorized, serverError } = require("../lib/response");

/**
 * authMiddleware sonrasında kullan. req.user.uid ile users tablosundan id bulur, req.userId set eder.
 * Kullanıcı yoksa 401 döner (önce GET /api/users/me ile oluşturulmalı).
 */
async function loadUser(req, res, next) {
  const uid = req.user?.uid;
  if (!uid) {
    return unauthorized(res, "UNAUTHORIZED", "Token gerekli");
  }
  try {
    const result = await pool.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [uid]
    );
    if (result.rows.length === 0) {
      return unauthorized(res, "USER_NOT_FOUND", "Kullanıcı bulunamadı. Önce giriş yapıp /api/users/me çağırın.");
    }
    req.userId = result.rows[0].id;
    next();
  } catch (err) {
    return serverError(res, err);
  }
}

module.exports = loadUser;
