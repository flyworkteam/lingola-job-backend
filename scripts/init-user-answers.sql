-- Kullanıcının verdiği cevaplar (kelime soruları, quiz vb.)
CREATE TABLE IF NOT EXISTS user_answers (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  user_answer TEXT,
  is_correct BOOLEAN NOT NULL,
  question_type VARCHAR(50),
  answered_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS user_answers_user_id_idx ON user_answers (user_id);
CREATE INDEX IF NOT EXISTS user_answers_word_id_idx ON user_answers (word_id);
CREATE INDEX IF NOT EXISTS user_answers_answered_at_idx ON user_answers (answered_at);
