-- Admin dashboard bildirimleri (müşteri/admin görsün)
-- Çalıştırma: mysql -u USER -p DB_NAME < migrations/003_admin_notifications.sql

CREATE TABLE IF NOT EXISTS admin_notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY admin_notifications_created_at_idx (created_at)
);
