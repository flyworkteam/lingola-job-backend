-- 1 gün girmeyen kullanıcıya bildirim için gerekli kolonlar.
-- Çalıştırma: mysql -u USER -p DB_NAME < migrations/001_inactivity_reminder.sql
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS last_activity_at DATETIME,
  ADD COLUMN IF NOT EXISTS fcm_token TEXT,
  ADD COLUMN IF NOT EXISTS last_reminder_sent_at DATETIME;

-- Mevcut kullanıcılar için last_activity_at başlangıç değeri
UPDATE users SET last_activity_at = updated_at WHERE last_activity_at IS NULL;
