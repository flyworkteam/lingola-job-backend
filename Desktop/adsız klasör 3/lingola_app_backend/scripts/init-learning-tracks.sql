CREATE TABLE IF NOT EXISTS learning_tracks (
  id SERIAL PRIMARY KEY,
  language_code VARCHAR(50) NOT NULL REFERENCES languages(code),
  title VARCHAR(150) NOT NULL,
  description TEXT,
  level VARCHAR(50),            -- örn: beginner / intermediate / advanced
  sort_order INTEGER DEFAULT 0, -- aynı dil için sıralama
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Frontend ile uyumlu: language_code = english, german, ... (languages.code ile aynı)
INSERT INTO learning_tracks (language_code, title, description, level, sort_order) VALUES
  ('english', 'Beginner Track', 'Start from the basics of English.', 'beginner', 1),
  ('english', 'Intermediate Track', 'Improve your vocabulary and grammar.', 'intermediate', 2),
  ('english', 'Advanced Track', 'Master advanced English usage.', 'advanced', 3)
ON CONFLICT DO NOTHING;

