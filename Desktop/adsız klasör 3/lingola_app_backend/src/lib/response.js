/**
 * Tutarlı API cevap formatı.
 * success: { success: true, data }
 * error:   { success: false, error: { code, message, details? } }
 */

function success(res, data, status = 200) {
  return res.status(status).json({ success: true, data });
}

function error(res, code, message, details = null, status = 400) {
  const body = { success: false, error: { code, message } };
  if (details != null) body.error.details = details;
  return res.status(status).json(body);
}

function validationError(res, code, message, details = null) {
  return error(res, code || "VALIDATION_ERROR", message, details, 400);
}

function notFound(res, code = "NOT_FOUND", message = "Kayıt bulunamadı") {
  return error(res, code, message, null, 404);
}

function unauthorized(res, code = "UNAUTHORIZED", message = "Yetkisiz") {
  return error(res, code, message, null, 401);
}

function serverError(res, err, message = "Sunucu hatası") {
  console.error("[serverError]", err);
  return error(res, "SERVER_ERROR", message, null, 500);
}

module.exports = {
  success,
  error,
  validationError,
  notFound,
  unauthorized,
  serverError,
};
