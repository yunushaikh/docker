#!/bin/bash

# Dynamic ProxySQL configuration script
# This script uses environment variables to configure ProxySQL

# Determine MariaDB client command based on version
# MariaDB 11.x uses 'mariadb' client, MariaDB 10.x uses 'mysql' client
MARIADB_VERSION=${MARIADB_VERSION:-10.11}
if [[ "$MARIADB_VERSION" == 11.* ]]; then
    MYSQL_CLIENT="mariadb"
else
    MYSQL_CLIENT="mysql"
fi

echo "Configuring ProxySQL with dynamic values using $MYSQL_CLIENT client..."

# Configure servers
$MYSQL_CLIENT -h 127.0.0.1 -P 6032 -u admin -padmin -e "
INSERT INTO mysql_servers(hostgroup_id, hostname, port, weight, status, comment) VALUES 
(0, 'galera-node1', 3306, 1000, 'ONLINE', 'Primary Galera Node'),
(0, 'galera-node2', 3306, 1000, 'ONLINE', 'Secondary Galera Node'),
(0, 'galera-node3', 3306, 1000, 'ONLINE', 'Secondary Galera Node');
"

# Configure users with environment variables
$MYSQL_CLIENT -h 127.0.0.1 -P 6032 -u admin -padmin -e "
INSERT INTO mysql_users(username, password, default_hostgroup, active, comment) VALUES 
('root', '${MYSQL_ROOT_PASSWORD}', 0, 1, 'Root user'),
('${MYSQL_USER}', '${MYSQL_PASSWORD}', 0, 1, 'Test user');
"

# Load configuration to runtime
$MYSQL_CLIENT -h 127.0.0.1 -P 6032 -u admin -padmin -e "
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
SAVE MYSQL USERS TO DISK;
"

echo "ProxySQL configuration completed!"
