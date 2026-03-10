-- 1 gün girmeyen kullanıcıya bildirim için gerekli kolonlar.
-- Çalıştırma: psql $DATABASE_URL -f migrations/001_inactivity_reminder.sql
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS fcm_token TEXT,
  ADD COLUMN IF NOT EXISTS last_reminder_sent_at TIMESTAMPTZ;

-- Mevcut kullanıcılar için last_activity_at başlangıç değeri
UPDATE users SET last_activity_at = updated_at WHERE last_activity_at IS NULL;
