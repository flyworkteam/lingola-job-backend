-- Kelimeler tablosu: her track'e ait kelimeler ve seviyeleri
CREATE TABLE IF NOT EXISTS words (
  id SERIAL PRIMARY KEY,
  learning_track_id INTEGER NOT NULL REFERENCES learning_tracks(id) ON DELETE CASCADE,
  word VARCHAR(255) NOT NULL,
  translation VARCHAR(500),
  level VARCHAR(50),
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Aynı track içinde aynı kelime tekrar olmasın
CREATE UNIQUE INDEX IF NOT EXISTS words_track_word_key ON words (learning_track_id, word);

-- Örnek kelimeler (Beginner track id=7, Intermediate=8, Advanced=9 varsayılıyor; gerçek id'ler DB'ye göre değişir)
-- Önce track id'lerini bulup ona göre insert yapmak için: learning_tracks tablosundaki id'leri kullan
INSERT INTO words (learning_track_id, word, translation, level, sort_order)
SELECT lt.id, w.word, w.translation, w.level, w.sort_order
FROM learning_tracks lt
CROSS JOIN (VALUES
  ('hello', 'merhaba', 'A1', 1),
  ('goodbye', 'hoşça kal', 'A1', 2),
  ('please', 'lütfen', 'A1', 3),
  ('thank you', 'teşekkürler', 'A1', 4),
  ('yes', 'evet', 'A1', 5),
  ('no', 'hayır', 'A1', 6),
  ('water', 'su', 'A1', 7),
  ('food', 'yiyecek', 'A1', 8),
  ('house', 'ev', 'A1', 9),
  ('book', 'kitap', 'A1', 10)
) AS w(word, translation, level, sort_order)
WHERE lt.language_code = 'english' AND lt.level = 'beginner'
ON CONFLICT (learning_track_id, word) DO NOTHING;

-- Intermediate için birkaç örnek (conflict olmaması için farklı kelimeler)
INSERT INTO words (learning_track_id, word, translation, level, sort_order)
SELECT lt.id, w.word, w.translation, w.level, w.sort_order
FROM learning_tracks lt
CROSS JOIN (VALUES
  ('however', 'ancak, bununla birlikte', 'B1', 1),
  ('although', 'rağmen, -e rağmen', 'B1', 2),
  ('experience', 'deneyim', 'B1', 3),
  ('opportunity', 'fırsat', 'B1', 4),
  ('environment', 'çevre, ortam', 'B1', 5)
) AS w(word, translation, level, sort_order)
WHERE lt.language_code = 'english' AND lt.level = 'intermediate'
ON CONFLICT (learning_track_id, word) DO NOTHING;

-- Advanced için birkaç örnek
INSERT INTO words (learning_track_id, word, translation, level, sort_order)
SELECT lt.id, w.word, w.translation, w.level, w.sort_order
FROM learning_tracks lt
CROSS JOIN (VALUES
  ('nevertheless', 'yine de, buna rağmen', 'C1', 1),
  ('approximately', 'yaklaşık olarak', 'C1', 2),
  ('responsibility', 'sorumluluk', 'C1', 3)
) AS w(word, translation, level, sort_order)
WHERE lt.language_code = 'english' AND lt.level = 'advanced'
ON CONFLICT (learning_track_id, word) DO NOTHING;
