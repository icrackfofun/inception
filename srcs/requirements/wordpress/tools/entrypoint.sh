#!/bin/bash
set -e

# Read Docker secrets
DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

# Ensure WordPress directory exists
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Configure PHP-FPM to listen on all interfaces for Nginx
PHP_POOL_CONF="/etc/php/8.2/fpm/pool.d/www.conf"
if ! grep -q "^listen = 0.0.0.0:9000" "$PHP_POOL_CONF"; then
    sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" "$PHP_POOL_CONF"
fi
sed -i 's/^listen.allowed_clients/#&/' "$PHP_POOL_CONF" || true

# Initialize WordPress if not present
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --path=/var/www/html --allow-root

    # Create wp-config.php
    wp config create \
        --path=/var/www/html \
        --dbname="${MYSQL_DB}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_USER_PASSWORD}" \
        --dbhost="${MYSQL_HOST}" \
        --skip-check \
        --allow-root

    # Install WordPress
    wp core install \
        --path=/var/www/html \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

wp option update home "${WP_URL}" --allow-root --path=/var/www/html
wp option update siteurl "${WP_URL}" --allow-root --path=/var/www/html

if ! grep -q "WP_HOME" /var/www/html/wp-config.php; then
cat << EOF >> /var/www/html/wp-config.php

define('WP_HOME', '${WP_URL}');
define('WP_SITEURL', '${WP_URL}');
EOF
fi

# Fix ownership just in case
chown -R www-data:www-data /var/www/html

# Start PHP-FPM in foreground (PID 1)
exec php-fpm8.2 -F

