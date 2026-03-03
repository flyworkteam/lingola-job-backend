/**
 * Basit body/query validasyonu. Eksik veya hatalı alanlarda 400 + tutarlı error döner.
 * schema: { fieldName: 'number' | 'string' | 'boolean' | 'required_string' }
 * - 'required_string' => string, boş olamaz
 */

const { validationError } = require("./response");

function validate(schema, source = "body") {
  return (req, res, next) => {
    const data = source === "query" ? req.query : req.body;
    const errors = [];

    for (const [key, type] of Object.entries(schema)) {
      const value = data[key];
      if (type === "number") {
        const n = value == null ? NaN : parseInt(value, 10);
        if (Number.isNaN(n) || n < 0) {
          errors.push({ field: key, message: `Geçersiz veya eksik: ${key}` });
        }
      } else if (type === "positive_number") {
        const n = value == null ? NaN : parseInt(value, 10);
        if (Number.isNaN(n) || n < 1) {
          errors.push({ field: key, message: `Geçerli bir sayı olmalı (≥1): ${key}` });
        }
      } else if (type === "boolean") {
        if (typeof value !== "boolean" && value !== "true" && value !== "false") {
          errors.push({ field: key, message: `true veya false olmalı: ${key}` });
        }
      } else if (type === "required_string") {
        if (value == null || String(value).trim() === "") {
          errors.push({ field: key, message: `Zorunlu alan: ${key}` });
        }
      } else if (type === "string") {
        // optional string, no check
      }
    }

    if (errors.length > 0) {
      return validationError(res, "VALIDATION_ERROR", "Geçersiz istek", errors);
    }
    next();
  };
}

module.exports = { validate };
