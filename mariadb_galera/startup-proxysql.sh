#!/bin/bash

# Wait for Galera cluster to be ready
echo "Waiting for Galera cluster to be ready..."
until mysql -h galera-node1 -P 3306 -u root -prootpassword -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for galera-node1..."
    sleep 5
done

until mysql -h galera-node2 -P 3306 -u root -prootpassword -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for galera-node2..."
    sleep 5
done

until mysql -h galera-node3 -P 3306 -u root -prootpassword -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for galera-node3..."
    sleep 5
done

echo "Galera cluster is ready!"

# Wait a bit more for cluster to stabilize
sleep 10

# Configure ProxySQL
echo "Configuring ProxySQL..."
mysql -h 127.0.0.1 -P 6032 -u admin -padmin < /etc/proxysql-init.sql

echo "ProxySQL configuration completed!"

# Keep the container running
tail -f /dev/null
