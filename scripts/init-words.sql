-- Kelimeler tablosu: her track'e ait kelimeler ve seviyeleri
CREATE TABLE IF NOT EXISTS words (
  id INT AUTO_INCREMENT PRIMARY KEY,
  learning_track_id INT NOT NULL,
  word VARCHAR(255) NOT NULL,
  translation VARCHAR(500),
  level VARCHAR(50),
  sort_order INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY words_track_word_key (learning_track_id, word),
  CONSTRAINT fk_words_learning_track
    FOREIGN KEY (learning_track_id) REFERENCES learning_tracks(id) ON DELETE CASCADE
);

-- Örnek kelimeler (Beginner track id=7, Intermediate=8, Advanced=9 varsayılıyor; gerçek id'ler DB'ye göre değişir)
-- Önce track id'lerini bulup ona göre insert yapmak için: learning_tracks tablosundaki id'leri kullan
INSERT INTO words (learning_track_id, word, translation, level, sort_order)
SELECT lt.id, seed.word, seed.translation, seed.level, seed.sort_order
FROM learning_tracks lt
JOIN (
  SELECT 'hello' AS word, 'merhaba' AS translation, 'A1' AS level, 1 AS sort_order
  UNION ALL SELECT 'goodbye', 'hoşça kal', 'A1', 2
  UNION ALL SELECT 'please', 'lütfen', 'A1', 3
  UNION ALL SELECT 'thank you', 'teşekkürler', 'A1', 4
  UNION ALL SELECT 'yes', 'evet', 'A1', 5
  UNION ALL SELECT 'no', 'hayır', 'A1', 6
  UNION ALL SELECT 'water', 'su', 'A1', 7
  UNION ALL SELECT 'food', 'yiyecek', 'A1', 8
  UNION ALL SELECT 'house', 'ev', 'A1', 9
  UNION ALL SELECT 'book', 'kitap', 'A1', 10
) AS seed
WHERE lt.language_code = 'english' AND lt.level = 'beginner'
ON DUPLICATE KEY UPDATE
  translation = VALUES(translation),
  level = VALUES(level),
  sort_order = VALUES(sort_order);

-- Intermediate için birkaç örnek (conflict olmaması için farklı kelimeler)
INSERT INTO words (learning_track_id, word, translation, level, sort_order)
SELECT lt.id, seed.word, seed.translation, seed.level, seed.sort_order
FROM learning_tracks lt
JOIN (
  SELECT 'however' AS word, 'ancak, bununla birlikte' AS translation, 'B1' AS level, 1 AS sort_order
  UNION ALL SELECT 'although', 'rağmen, -e rağmen', 'B1', 2
  UNION ALL SELECT 'experience', 'deneyim', 'B1', 3
  UNION ALL SELECT 'opportunity', 'fırsat', 'B1', 4
  UNION ALL SELECT 'environment', 'çevre, ortam', 'B1', 5
) AS seed
WHERE lt.language_code = 'english' AND lt.level = 'intermediate'
ON DUPLICATE KEY UPDATE
  translation = VALUES(translation),
  level = VALUES(level),
  sort_order = VALUES(sort_order);

-- Advanced için birkaç örnek
INSERT INTO words (learning_track_id, word, translation, level, sort_order)
SELECT lt.id, seed.word, seed.translation, seed.level, seed.sort_order
FROM learning_tracks lt
JOIN (
  SELECT 'nevertheless' AS word, 'yine de, buna rağmen' AS translation, 'C1' AS level, 1 AS sort_order
  UNION ALL SELECT 'approximately', 'yaklaşık olarak', 'C1', 2
  UNION ALL SELECT 'responsibility', 'sorumluluk', 'C1', 3
) AS seed
WHERE lt.language_code = 'english' AND lt.level = 'advanced'
ON DUPLICATE KEY UPDATE
  translation = VALUES(translation),
  level = VALUES(level),
  sort_order = VALUES(sort_order);
