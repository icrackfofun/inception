# Variables
COMPOSE_FILE = srcs/docker-compose.yml
SERVICES = mariadb wordpress nginx
DATA_DIR = /home/psantos-/data

.PHONY: all build up down clean restart

# Default: build and start all services
all: build up

# Build Docker images for all services
build:
	docker compose -f $(COMPOSE_FILE) build --no-cache $(SERVICES)

# Start all services
up:
	docker compose -f $(COMPOSE_FILE) up -d $(SERVICES)

# Stop all services
down:
	docker compose -f $(COMPOSE_FILE) down

# Remove images and volumes
clean: down
	docker compose -f $(COMPOSE_FILE) down --rmi all -v

# Restart all services
restart: down up

