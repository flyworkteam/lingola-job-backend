-- Tablo zaten varsa ve ad/soyad sütunları yoksa bunu çalıştır.
-- psql -U postgres -d lingola -f scripts/add_user_name_columns.sql

ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS display_name VARCHAR(255);
