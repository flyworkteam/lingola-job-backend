-- Kullanıcının her track için ilerlemesi (bir kullanıcı–track kombinasyonu tek satır)
CREATE TABLE IF NOT EXISTS user_tracks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  learning_track_id INT NOT NULL,
  progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  completed_words_count INTEGER DEFAULT 0,
  started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  last_accessed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY user_tracks_user_learning_track_key (user_id, learning_track_id),
  KEY user_tracks_user_id_idx (user_id),
  KEY user_tracks_learning_track_id_idx (learning_track_id),
  CONSTRAINT fk_user_tracks_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_tracks_learning_track
    FOREIGN KEY (learning_track_id) REFERENCES learning_tracks(id) ON DELETE CASCADE
);
