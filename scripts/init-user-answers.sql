-- Kullanıcının verdiği cevaplar (kelime soruları, quiz vb.)
CREATE TABLE IF NOT EXISTS user_answers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  word_id INT NOT NULL,
  user_answer TEXT,
  is_correct BOOLEAN NOT NULL,
  question_type VARCHAR(50),
  answered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY user_answers_user_id_idx (user_id),
  KEY user_answers_word_id_idx (word_id),
  KEY user_answers_answered_at_idx (answered_at),
  CONSTRAINT fk_user_answers_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_answers_word
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);
