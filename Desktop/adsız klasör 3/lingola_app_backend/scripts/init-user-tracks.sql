-- Kullanıcının her track için ilerlemesi (bir kullanıcı–track kombinasyonu tek satır)
CREATE TABLE IF NOT EXISTS user_tracks (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  learning_track_id INTEGER NOT NULL REFERENCES learning_tracks(id) ON DELETE CASCADE,
  progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  completed_words_count INTEGER DEFAULT 0,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, learning_track_id)
);

CREATE INDEX IF NOT EXISTS user_tracks_user_id_idx ON user_tracks (user_id);
CREATE INDEX IF NOT EXISTS user_tracks_learning_track_id_idx ON user_tracks (learning_track_id);
