FROM debian:bookworm-slim

# Install MariaDB and utilities
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client gosu && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration and scripts
COPY tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /entrypoint.sh
COPY tools/init.sql /etc/mysql/init.sql
RUN chmod +x /entrypoint.sh

# Ensure socket dir exists
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Expose port
EXPOSE 3306

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
