FROM debian:bookworm-slim

# Install PHP, PHP-FPM, and required extensions for WordPress
RUN apt-get update && \
    apt-get install -y \
        php8.2 php8.2-fpm php8.2-mysql php8.2-gd \
        php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip \
        wget unzip curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create runtime directories
RUN mkdir -p /run/php

# Copy entrypoint script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose PHP-FPM port
EXPOSE 9000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
