-- Mevcut veritabanını güncel şemaya getirir (native_name vb.).
-- Yeni kurulumlarda init-*.sql yeterli; bu dosya sadece eski DB'ler için.

-- languages.native_name (yoksa ekle)
ALTER TABLE languages ADD COLUMN IF NOT EXISTS native_name VARCHAR(100) DEFAULT '';
UPDATE languages SET native_name = '' WHERE native_name IS NULL;
