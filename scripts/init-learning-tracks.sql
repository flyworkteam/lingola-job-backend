CREATE TABLE IF NOT EXISTS learning_tracks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  language_code VARCHAR(50) NOT NULL,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  level VARCHAR(50),            -- örn: beginner / intermediate / advanced
  sort_order INTEGER DEFAULT 0, -- aynı dil için sıralama
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY learning_tracks_language_title_key (language_code, title),
  CONSTRAINT fk_learning_tracks_language
    FOREIGN KEY (language_code) REFERENCES languages(code)
);

-- Frontend ile uyumlu: language_code = english, german, ... (languages.code ile aynı)
INSERT INTO learning_tracks (language_code, title, description, level, sort_order) VALUES
  ('english', 'Beginner Track', 'Start from the basics of English.', 'beginner', 1),
  ('english', 'Intermediate Track', 'Improve your vocabulary and grammar.', 'intermediate', 2),
  ('english', 'Advanced Track', 'Master advanced English usage.', 'advanced', 3)
ON DUPLICATE KEY UPDATE
  title = VALUES(title);

