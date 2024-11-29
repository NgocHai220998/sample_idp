CREATE DATABASE IF NOT EXISTS sample_id_production;
CREATE USER IF NOT EXISTS 'sample_id'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON sample_id_production.* TO 'sample_id'@'%';
FLUSH PRIVILEGES;
