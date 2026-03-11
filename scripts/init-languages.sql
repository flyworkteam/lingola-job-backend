-- Diller tablosu (frontend id = code: english, german, turkish, ...)
CREATE TABLE IF NOT EXISTS languages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  native_name VARCHAR(100) DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Mevcut tabloda native_name yoksa ekle (migration)
ALTER TABLE languages ADD COLUMN IF NOT EXISTS native_name VARCHAR(100) DEFAULT '';
UPDATE languages SET native_name = '' WHERE native_name IS NULL;

-- Uygulamada kullanılan 11 dil (frontend _languages listesi ile uyumlu)
INSERT INTO languages (code, name, native_name) VALUES
  ('english', 'English', 'English'),
  ('german', 'German', 'Deutsch'),
  ('italian', 'Italian', 'Italiano'),
  ('french', 'French', 'Français'),
  ('japanese', 'Japanese', '日本語'),
  ('spanish', 'Spanish', 'Español'),
  ('russian', 'Russian', 'Русский'),
  ('turkish', 'Turkish', 'Türkçe'),
  ('korean', 'Korean', '한국어'),
  ('hindi', 'Hindi', 'हिन्दी'),
  ('portuguese', 'Portuguese', 'Português')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  native_name = COALESCE(NULLIF(VALUES(native_name), ''), native_name);
