-- Initial database setup for Galera cluster
-- This script runs on all nodes during initialization

-- Create additional databases if needed
CREATE DATABASE IF NOT EXISTS galera_test;
CREATE DATABASE IF NOT EXISTS performance_schema;

-- Create additional users for testing
CREATE USER IF NOT EXISTS 'galera_user'@'%' IDENTIFIED BY 'galera_pass';
GRANT ALL PRIVILEGES ON *.* TO 'galera_user'@'%' WITH GRANT OPTION;

-- Create a test table
USE testdb;
CREATE TABLE IF NOT EXISTS test_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some test data
INSERT INTO test_table (name) VALUES 
    ('Galera Node 1'),
    ('Galera Node 2'),
    ('Galera Node 3')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Show cluster information
SELECT 'Galera cluster initialized successfully' as status;
