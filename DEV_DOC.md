This document is intended for developers who want to understand, build, run, and maintain the project from scratch. It explains the required environment, configuration files, secrets management, container orchestration, and how data persistence is achieved using Docker technologies.

The goal is to allow a developer to reproduce the full infrastructure reliably on a clean system.

* * * * *

**Environment Setup from Scratch**


### **System Prerequisites**

Before starting, ensure the following software is installed on the host machine:

-   Docker (engine)

-   Docker Compose (v2)

-   GNU Make

-   A Linux-based system (as required by the project)

Docker must be running and the current user must have permission to execute Docker commands.

You can verify the installation with:

`docker --version
docker compose version
make --version`

* * * * *

### **Repository Structure**

The repository follows a strict structure required by the project:

`.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .env
├── .gitignore
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/`

All Docker-related configuration is contained inside the `srcs/` directory. Each service has its own subdirectory with a dedicated Dockerfile and tools.

* * * * *

**Configuration Files and Secrets**


### **Environment Variables**

Non-sensitive configuration values are defined in the `.env` file at the root of the repository. This file is loaded automatically by Docker Compose.

Typical values include:

-   WordPress site URL

-   Database name

-   Database user

-   Container hostnames

The `.env` file is intentionally excluded from version control.

* * * * *

### **Secrets Management**

Sensitive credentials are handled using Docker secrets instead of environment variables.

Secrets include:

-   MariaDB root password

-   WordPress database user password

-   WordPress administrator password

These secrets are stored as plain files inside a `secrets/` directory and mounted read-only into the containers at runtime under `/run/secrets/`.

This approach ensures:

-   Passwords are never baked into images

-   Secrets are not visible through `docker inspect`

-   Credentials are not committed to the repository

* * * * *

**Building and Launching the Project**


### **Build and Run**

From the root of the repository, run:

`make`

This command:

-   Builds all Docker images using Docker Compose

-   Creates the Docker network

-   Starts all services in the correct order

On the first launch, MariaDB initializes the database, and WordPress is installed automatically using WP-CLI.

* * * * *

### **Stopping the Project**

To stop the containers without deleting persistent data:

`make down`

Containers are removed, but volumes and networks are preserved.

* * * * *

### **Cleaning Docker Resources**

To remove images, volumes, and networks (without deleting host data manually):

`make clean`

This is typically used during development when a full reset of the Docker environment is required.

* * * * *

**Managing Containers and Volumes**


### **Container Management**

Check container status:

`docker compose ps`

Inspect logs:

`docker logs nginx
docker logs wordpress
docker logs mariadb`

Restart a single service:

`docker compose restart wordpress`

Enter a running container:

`docker exec -it wordpress sh`

* * * * *

### **Volume Management and Persistence**

Docker volumes are used to persist data on the host system.

To list volumes:

`docker volume ls`

Inspect a volume:

`docker volume inspect <volume_name>`

Volumes are mapped to:

`/home/<login>/data/`

This ensures:

-   WordPress files persist across rebuilds

-   Database data survives container crashes

-   System reboots do not affect application state

* * * * *

**Data Storage and Persistence Model**


### **WordPress Data**

The WordPress container stores:

-   Core WordPress files

-   Uploaded media

-   Themes and plugins

These are stored in a Docker volume mounted at:

`/var/www/html`

* * * * *

### **MariaDB Data**

The MariaDB container stores:

-   Database files

-   User credentials

-   WordPress content

These are stored in a Docker volume mounted at:

`/var/lib/mysql`

* * * * *

### **Persistence Guarantees**

Because Docker volumes are used:

-   Rebuilding images does not delete content

-   Restarting containers preserves configuration

-   Crashes do not cause data loss

This design fulfills the persistence requirement of the project.

* * * * *

**Docker Compose and Networking**


All services communicate through a dedicated Docker bridge network defined in `docker-compose.yml`.

This network:

-   Is isolated from the host

-   Allows containers to communicate using service names

-   Prevents external access to internal services such as MariaDB and PHP-FPM

To verify the network:

`docker network ls`