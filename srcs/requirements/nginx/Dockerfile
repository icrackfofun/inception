FROM debian:bookworm-slim

# Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directories for SSL certs
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=psantos-.42.fr"

# Copy Nginx config
COPY ./tools/nginx.conf /etc/nginx/conf.d/nginx.conf

# Ensure /var/www/html exists (volume will mount here)
RUN mkdir -p /var/www/html

# Expose HTTPS
EXPOSE 443

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]


