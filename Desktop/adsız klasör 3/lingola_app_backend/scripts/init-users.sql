-- Kullanıcılar tablosu (ad, soyad, email, Firebase UID)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  email VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- firebase_uid ile tekrar kayıt engellemek için (zaten UNIQUE var)
CREATE UNIQUE INDEX IF NOT EXISTS users_firebase_uid_key ON users (firebase_uid);

-- Eğer tabloyu daha önce email/firebase_uid ile oluşturduysanız, sütunları ekleyin:
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);
