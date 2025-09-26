#!/bin/bash

# Determine MariaDB client command based on version
# MariaDB 11.x uses 'mariadb' client, MariaDB 10.x uses 'mysql' client
MARIADB_VERSION=${MARIADB_VERSION:-10.11}
if [[ "$MARIADB_VERSION" == 11.* ]]; then
    MYSQL_CLIENT="mariadb"
else
    MYSQL_CLIENT="mysql"
fi

echo "Using MariaDB version: $MARIADB_VERSION with client: $MYSQL_CLIENT"

# Wait for Galera cluster to be ready
echo "Waiting for Galera cluster to be ready..."
until $MYSQL_CLIENT -h galera-node1 -P 3306 -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for galera-node1..."
    sleep 5
done

until $MYSQL_CLIENT -h galera-node2 -P 3306 -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for galera-node2..."
    sleep 5
done

until $MYSQL_CLIENT -h galera-node3 -P 3306 -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for galera-node3..."
    sleep 5
done

echo "Galera cluster is ready!"

# Wait a bit more for cluster to stabilize
sleep 10

# Configure ProxySQL
echo "Configuring ProxySQL..."
# Use dynamic configuration script that handles environment variables
/configure-proxysql.sh

echo "ProxySQL configuration completed!"

# Keep the container running
tail -f /dev/null
