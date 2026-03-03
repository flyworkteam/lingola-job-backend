# Veritabanı ve terminal testi

## 1. Ad/soyad sütunları

Tabloyu **henüz oluşturmadıysan** (ilk kez):

```bash
psql -U postgres -d lingola -f scripts/init_users_table.sql
```

Tabloyu **zaten oluşturduysan**, sadece ad/soyad sütunlarını ekle:

```bash
psql -U postgres -d lingola -f scripts/add_user_name_columns.sql
```

## 2. Backend’in yapması gereken

Google ile girişte Firebase token doğrulanınca (`verifyIdToken`) şu alanlar gelir:

- `decoded.uid` → `firebase_uid`
- `decoded.email` → `email`
- `decoded.name` veya `decoded.firebase.sign_in_provider` → tam ad; istersen boşluğa göre bölüp `first_name` / `last_name` yaz.

Örnek (Node.js): `decoded.name` tek string (örn. "Kadir Karataş"); bunu boşluğa göre bölüp `first_name` / `last_name` doldurabilir veya hepsini `display_name`e yazabilirsin. Sonra `INSERT ... ON CONFLICT (firebase_uid) DO UPDATE SET email=..., first_name=..., last_name=...` ile kaydet.

## 3. Terminalde kullanıcıları görmek

Uygulamada Google ile giriş yaptıktan sonra (backend bu kullanıcıyı DB’ye yazdıysa):

```bash
psql -U lingola_user -d lingola -c "SELECT id, firebase_uid, email, first_name, last_name, display_name, created_at FROM users;"
```

Veya psql içinde:

```bash
psql -U lingola_user -d lingola
```

```sql
SELECT * FROM users;
```

Burada `first_name`, `last_name`, `display_name` dolu olacak; backend token’dan okuyup yazdığı sürece terminalde ad soyadı görürsün.
