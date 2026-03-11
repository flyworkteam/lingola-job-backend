-- Mevcut veritabanında 2 harfli dil kodları (en, de, tr...) varsa
-- frontend ile uyumlu kodlara (english, german, ...) çevirir.
-- learning_tracks.language_code da güncellenir.

-- 1) learning_tracks: en -> english (diğer dillerde track yoksa sadece en yeterli)
UPDATE learning_tracks SET language_code = 'english' WHERE language_code = 'en';

-- 2) languages: 2 harfli kodu frontend id ile değiştir (çakışma olmaması için önce geçici değer)
UPDATE languages SET code = 'english'   WHERE code = 'en';
UPDATE languages SET code = 'german'   WHERE code = 'de';
UPDATE languages SET code = 'italian'  WHERE code = 'it';
UPDATE languages SET code = 'french'   WHERE code = 'fr';
UPDATE languages SET code = 'japanese' WHERE code = 'ja';
UPDATE languages SET code = 'spanish' WHERE code = 'es';
UPDATE languages SET code = 'russian' WHERE code = 'ru';
UPDATE languages SET code = 'turkish' WHERE code = 'tr';
UPDATE languages SET code = 'korean'  WHERE code = 'ko';
UPDATE languages SET code = 'hindi'   WHERE code = 'hi';
UPDATE languages SET code = 'portuguese' WHERE code = 'pt';

-- 3) Frontend'de olmayan dil (Arabic) varsa sil
DELETE FROM languages WHERE code = 'ar';

-- 4) Eksikse Hindi ekle (bazı DB'lerde hi yok)
INSERT INTO languages (code, name) VALUES ('hindi', 'Hindi')
ON DUPLICATE KEY UPDATE
  name = VALUES(name);
