-- Mevcut veritabanını güncel şemaya getirir (native_name vb.).
-- Yeni kurulumlarda init-*.sql yeterli; bu dosya sadece eski DB'ler için.

-- languages.native_name (yoksa ekle)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'languages' AND column_name = 'native_name'
  ) THEN
    ALTER TABLE languages ADD COLUMN native_name VARCHAR(100) DEFAULT '';
    UPDATE languages SET native_name = '' WHERE native_name IS NULL;
  END IF;
END $$;
