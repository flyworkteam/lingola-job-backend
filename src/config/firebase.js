const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const serviceAccountPath = path.join(__dirname, "lingola-backend-firebase-service-account.json");

function isValidServiceAccount(value) {
  return Boolean(
    value &&
      typeof value === "object" &&
      typeof value.project_id === "string" &&
      value.project_id.trim() !== "" &&
      typeof value.client_email === "string" &&
      value.client_email.trim() !== "" &&
      typeof value.private_key === "string" &&
      value.private_key.trim() !== ""
  );
}

function loadServiceAccount() {
  const rawEnvJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (rawEnvJson && rawEnvJson.trim() !== "") {
    try {
      const parsed = JSON.parse(rawEnvJson);
      if (isValidServiceAccount(parsed)) return parsed;
      console.warn("[firebase] FIREBASE_SERVICE_ACCOUNT_JSON eksik alanlar içeriyor.");
    } catch (err) {
      console.warn("[firebase] FIREBASE_SERVICE_ACCOUNT_JSON parse edilemedi:", err.message);
    }
  }

  try {
    if (!fs.existsSync(serviceAccountPath)) return null;
    const fileContent = fs.readFileSync(serviceAccountPath, "utf8").trim();
    if (fileContent === "") return null;

    const parsed = JSON.parse(fileContent);
    if (isValidServiceAccount(parsed)) return parsed;

    console.warn("[firebase] Service account dosyası placeholder veya eksik alanlar içeriyor.");
  } catch (err) {
    console.warn("[firebase] Service account dosyası okunamadı:", err.message);
  }

  return null;
}

const serviceAccount = loadServiceAccount();

if (serviceAccount && admin.apps.length === 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else if (!serviceAccount) {
  console.warn("[firebase] Firebase Admin başlatılmadı. Geçerli servis hesabı bulunamadı.");
}

module.exports = admin;