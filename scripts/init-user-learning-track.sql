-- Kullanıcının seçtiği learning track (users tablosuna sütun ekleme)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS learning_track_id INTEGER REFERENCES learning_tracks(id);

-- İsteğe bağlı: seçili track'e hızlı erişim için index
CREATE INDEX IF NOT EXISTS users_learning_track_id_idx ON users (learning_track_id);
