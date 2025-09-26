-- ProxySQL initialization script
-- This script configures ProxySQL with Galera cluster servers and users

-- Add Galera cluster servers
INSERT INTO mysql_servers(hostgroup_id, hostname, port, weight, status, comment) VALUES 
(0, 'galera-node1', 3306, 1000, 'ONLINE', 'Primary Galera Node'),
(0, 'galera-node2', 3306, 1000, 'ONLINE', 'Secondary Galera Node'),
(0, 'galera-node3', 3306, 1000, 'ONLINE', 'Secondary Galera Node');

-- Add MySQL users
INSERT INTO mysql_users(username, password, default_hostgroup, active, comment) VALUES 
('root', 'rootpassword', 0, 1, 'Root user'),
('testuser', 'testpass', 0, 1, 'Test user');

-- Load configuration to runtime
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL USERS TO RUNTIME;

-- Save configuration to disk
SAVE MYSQL SERVERS TO DISK;
SAVE MYSQL USERS TO DISK;

-- Show configured servers
SELECT * FROM mysql_servers;
SELECT * FROM mysql_users;
