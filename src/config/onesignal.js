const ONESIGNAL_API_URL = "https://api.onesignal.com/notifications?c=push";

function isConfigured() {
  return Boolean(process.env.ONESIGNAL_REST_API_KEY && process.env.ONESIGNAL_APP_ID);
}

async function sendToSubscriptionIds(subscriptionIds, title, body) {
  if (!isConfigured()) {
    throw new Error("OneSignal ayarlari eksik: ONESIGNAL_REST_API_KEY ve ONESIGNAL_APP_ID gerekli");
  }

  if (!Array.isArray(subscriptionIds) || subscriptionIds.length === 0) {
    throw new Error("OneSignal subscription id listesi bos olamaz");
  }

  const response = await fetch(ONESIGNAL_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Key ${process.env.ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: process.env.ONESIGNAL_APP_ID,
      include_subscription_ids: subscriptionIds,
      headings: { en: title, tr: title },
      contents: { en: body, tr: body },
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`OneSignal API hatasi (${response.status}): ${text}`);
  }

  return response.json();
}

module.exports = {
  isConfigured,
  sendToSubscriptionIds,
};
