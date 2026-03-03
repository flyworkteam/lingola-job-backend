-- 1) Postgres süper kullanıcısı ile çalıştır (psql -U postgres -d lingola)
--    Böylece lingola_user public şemada tablo oluşturabilir.

GRANT USAGE ON SCHEMA public TO lingola_user;
GRANT CREATE ON SCHEMA public TO lingola_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO lingola_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO lingola_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO lingola_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO lingola_user;

-- 2) Tabloyu oluştur (yine postgres ile veya artık lingola_user ile bağlanıp çalıştırabilirsin).

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    display_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT ALL ON users TO lingola_user;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO lingola_user;
