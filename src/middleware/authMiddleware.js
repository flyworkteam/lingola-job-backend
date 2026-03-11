const admin = require("../config/firebase"); // Firebase Admin SDK
const { unauthorized } = require("../lib/response");

async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return unauthorized(res, "MISSING_TOKEN", "Token yok");
    }

    const token = authHeader.split("Bearer ")[1];
    if (!token) {
      return unauthorized(res, "INVALID_TOKEN_FORMAT", "Token formatı yanlış");
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken; // uid, email

    next();
  } catch (err) {
    console.log("[auth] Geçersiz token veya hata:", err.message || err);
    return unauthorized(res, "INVALID_TOKEN", "Geçersiz token");
  }
}

module.exports = authMiddleware;