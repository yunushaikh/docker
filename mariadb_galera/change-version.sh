#!/bin/bash

# Script to change MariaDB version in the Galera cluster
# Usage: ./change-version.sh <version>
# Example: ./change-version.sh 10.10

if [ $# -eq 0 ]; then
    echo "Usage: $0 <mariadb-version>"
    echo "Available versions: 11.4, 11.3, 11.2, 11.1, 11.0, 10.11, 10.10, 10.9, 10.8, 10.7, 10.6, 10.5, 10.4, 10.3, 10.2, 10.1"
    echo "Current version: $(grep MARIADB_VERSION .env | cut -d'=' -f2)"
    exit 1
fi

VERSION=$1

# Update the .env file
sed -i "s/MARIADB_VERSION=.*/MARIADB_VERSION=$VERSION/" .env

echo "Updated MariaDB version to $VERSION in .env file"
echo "To apply changes, run:"
echo "  docker compose down -v"
echo "  docker compose up -d"
