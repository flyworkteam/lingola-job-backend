-- Kullanıcının seçtiği learning track (users tablosuna sütun ekleme)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS learning_track_id INT NULL,
  ADD CONSTRAINT fk_users_learning_track
    FOREIGN KEY (learning_track_id) REFERENCES learning_tracks(id);

-- İsteğe bağlı: seçili track'e hızlı erişim için index
CREATE INDEX users_learning_track_id_idx ON users (learning_track_id);
