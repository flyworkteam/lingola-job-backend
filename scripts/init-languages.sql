-- Diller tablosu (frontend id = code: english, german, turkish, ...)
CREATE TABLE IF NOT EXISTS languages (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  native_name VARCHAR(100) DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mevcut tabloda native_name yoksa ekle (migration)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'languages' AND column_name = 'native_name'
  ) THEN
    ALTER TABLE languages ADD COLUMN native_name VARCHAR(100) DEFAULT '';
    UPDATE languages SET native_name = '' WHERE native_name IS NULL;
    ALTER TABLE languages ALTER COLUMN native_name SET DEFAULT '';
  END IF;
END $$;

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
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  native_name = COALESCE(NULLIF(EXCLUDED.native_name, ''), languages.native_name);
