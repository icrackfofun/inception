#!/bin/bash
set -e

# Read secrets
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_USER_PASSWORD="$(cat /run/secrets/db_user_password)"

# Ensure socket directory exists
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# First-time initialization only
if [ ! -d "/var/lib/mysql/mysql" ]; then

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    mysqld --user=root --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    sleep 5

    mysql --socket=/run/mysqld/mysqld.sock -u root <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

# Start MariaDB in foreground
exec mysqld_safe
