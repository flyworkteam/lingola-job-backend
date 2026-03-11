-- Ödeme ve abonelik modülü.
-- Çalıştırma: mysql -u USER -p DB_NAME < migrations/002_subscriptions.sql

-- Abonelik planları (opsiyonel; RevenueCat'ten de okunabilir)
CREATE TABLE IF NOT EXISTS subscription_plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  duration_days INTEGER NOT NULL,
  price_cents INTEGER,
  currency VARCHAR(3) DEFAULT 'TRY',
  is_active BOOLEAN DEFAULT true,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Varsayılan planlar
INSERT INTO subscription_plans (product_id, name, description, duration_days, price_cents, currency)
VALUES
  ('lingola_premium_monthly', 'Aylık Premium', 'Tüm premium özelliklere aylık erişim', 30, 4999, 'TRY'),
  ('lingola_premium_yearly', 'Yıllık Premium', 'Tüm premium özelliklere yıllık erişim (2 ay ücretsiz)', 365, 39999, 'TRY')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  duration_days = VALUES(duration_days),
  price_cents = VALUES(price_cents),
  currency = VALUES(currency);

-- Kullanıcı abonelikleri
CREATE TABLE IF NOT EXISTS subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  plan_id INT NULL,
  product_id VARCHAR(100),
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME,
  cancelled_at DATETIME,
  platform VARCHAR(50),
  revenuecat_customer_id VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY subscriptions_user_id_idx (user_id),
  KEY subscriptions_status_idx (status),
  KEY subscriptions_expires_at_idx (expires_at),
  CONSTRAINT fk_subscriptions_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_subscriptions_plan
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id)
);

-- Webhook idempotency (aynı event tekrar işlenmesin)
CREATE TABLE IF NOT EXISTS webhook_events (
  id VARCHAR(255) PRIMARY KEY,
  event_type VARCHAR(100),
  app_user_id VARCHAR(128),
  processed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  payload JSON
);
