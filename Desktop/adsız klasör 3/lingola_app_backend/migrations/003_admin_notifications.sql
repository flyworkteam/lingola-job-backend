-- Admin dashboard bildirimleri (müşteri/admin görsün)
-- Çalıştırma: psql $DATABASE_URL -f migrations/003_admin_notifications.sql

CREATE TABLE IF NOT EXISTS admin_notifications (
  id SERIAL PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS admin_notifications_created_at_idx ON admin_notifications (created_at DESC);
