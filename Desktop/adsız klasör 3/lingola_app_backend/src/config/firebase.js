const admin = require("firebase-admin");
const serviceAccount = require("./lingola-backend-firebase-service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;