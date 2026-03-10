-- Ödeme ve abonelik modülü.
-- Çalıştırma: psql $DATABASE_URL -f migrations/002_subscriptions.sql

-- Abonelik planları (opsiyonel; RevenueCat'ten de okunabilir)
CREATE TABLE IF NOT EXISTS subscription_plans (
  id SERIAL PRIMARY KEY,
  product_id VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  duration_days INTEGER NOT NULL,
  price_cents INTEGER,
  currency VARCHAR(3) DEFAULT 'TRY',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Varsayılan planlar
INSERT INTO subscription_plans (product_id, name, description, duration_days, price_cents, currency)
VALUES
  ('lingola_premium_monthly', 'Aylık Premium', 'Tüm premium özelliklere aylık erişim', 30, 4999, 'TRY'),
  ('lingola_premium_yearly', 'Yıllık Premium', 'Tüm premium özelliklere yıllık erişim (2 ay ücretsiz)', 365, 39999, 'TRY')
ON CONFLICT (product_id) DO NOTHING;

-- Kullanıcı abonelikleri
CREATE TABLE IF NOT EXISTS subscriptions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_id INTEGER REFERENCES subscription_plans(id),
  product_id VARCHAR(100),
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  started_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  platform VARCHAR(50),
  revenuecat_customer_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS subscriptions_user_id_idx ON subscriptions (user_id);
CREATE INDEX IF NOT EXISTS subscriptions_status_idx ON subscriptions (status);
CREATE INDEX IF NOT EXISTS subscriptions_expires_at_idx ON subscriptions (expires_at);

-- Webhook idempotency (aynı event tekrar işlenmesin)
CREATE TABLE IF NOT EXISTS webhook_events (
  id VARCHAR(255) PRIMARY KEY,
  event_type VARCHAR(100),
  app_user_id VARCHAR(128),
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  payload JSONB
);
