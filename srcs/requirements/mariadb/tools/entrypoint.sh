#!/bin/bash
set -e

# Read secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)

# Ensure /run/mysqld exists for the socket
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialize MariaDB if empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Replace placeholder password in init.sql
sed -i "s/wordpresspass/${DB_USER_PASSWORD}/g" /etc/mysql/init.sql

# Start MariaDB in background
mysqld --user=mysql --init-file=/etc/mysql/init.sql &
pid="$!"

# Wait for background server to start
sleep 5

# Set root password if not set
mysqladmin -u root password "$DB_ROOT_PASSWORD" || true

# Bring MariaDB to foreground
wait "$pid"

