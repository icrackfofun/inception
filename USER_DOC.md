**Overview of the Services**


This project provides a complete web stack deployed using Docker Compose. The stack is composed of three main services, each running in its own isolated container and connected through a private Docker network.

**Nginx (Web Server)**\
Nginx acts as the single public entry point to the application. It listens **only on port 443** and serves the WordPress website over HTTPS using a TLS certificate. Nginx does not execute PHP code itself; instead, it forwards PHP requests to the WordPress container using FastCGI. This separation improves security and follows industry best practices.

**WordPress with PHP-FPM (Application Layer)**\
The WordPress container runs PHP-FPM, which is responsible for executing PHP code. WordPress handles all application logic, including page rendering, user authentication, content management, and administration. The container communicates with MariaDB to store and retrieve content.

**MariaDB (Database)**\
MariaDB stores all persistent data for WordPress, including users, posts, comments, and configuration. The database runs in its own container and uses a Docker volume to ensure data persistence across restarts, crashes, or rebuilds.

Together, these services form a secure, modular, and persistent web application.

* * * * *

**Starting the Project**


To start the project, ensure Docker and Docker Compose are installed and running on the system.

From the root of the repository, run:

`make`

This command builds the Docker images (if they do not already exist) and starts all services using Docker Compose. During the first launch, the database and WordPress installation are automatically initialized.

Once started, the containers will continue running in the background.

* * * * *

**Stopping the Project**


To stop all services while preserving data, run:

`make down`

This stops and removes the containers but **does not delete volumes or networks**, ensuring that all WordPress content and database data remain intact.

If the system is rebooted, the project can be restarted using the same `make` command.

* * * * *

**Accessing the Website**


The website is accessible only through HTTPS.

Open a browser and navigate to:

`https://<login>.42.fr`

Replace `<login>` with the project owner's login. A self-signed certificate is used, so the browser may display a security warning. This is expected behavior and can be safely bypassed.

Access via HTTP (`http://<login>.42.fr`) is intentionally disabled and should fail.

* * * * *

**Accessing the Administration Panel**


To access the WordPress administration dashboard, navigate to:

`https://<login>.42.fr/wp-admin`

Log in using the administrator credentials configured during setup. The administrator username does **not** include "admin" or "Admin", in accordance with the project rules.

From the dashboard, administrators can:

-   Edit pages and posts

-   Manage users

-   Configure WordPress settings

-   Install themes or plugins (if enabled)

Any changes made through the admin panel are stored persistently.

* * * * *

**Locating and Managing Credentials**


Sensitive credentials are **not stored in the repository**. They are managed securely using Docker secrets and environment variables.

**Secrets**\
Passwords such as:

-   MariaDB root password

-   WordPress database user password

-   WordPress administrator password

are stored in files located in the `secrets/` directory. These files are mounted into the containers at runtime and never embedded into Docker images.

**Environment Variables**\
Non-sensitive configuration values, such as database names, usernames, and site URLs, are defined in a `.env` file at the root of the project.

To update credentials:

1.  Stop the project using `make down`

2.  Update the relevant secret file or `.env` variable

3.  Restart the project using `make`

* * * * *

**Checking That Services Are Running Correctly**


Several commands are available to verify that the stack is healthy.

**List running containers**:

`docker compose ps`

All services (`nginx`, `wordpress`, `mariadb`) should appear as `Up`.

**Check container logs**:

`docker logs nginx
docker logs wordpress
docker logs mariadb`

These logs help diagnose startup issues or runtime errors.

**Verify Docker volumes (data persistence)**:

`docker volume ls
docker volume inspect <volume_name>`

Volumes should be mapped to `/home/<login>/data/`, ensuring persistence.

**Verify Docker network**:

`docker network ls`

A custom bridge network (e.g., `srcs_inception`) should exist, allowing containers to communicate securely using service names.

* * * * *

**Persistence and Reliability**


All critical data is stored in Docker volumes. This guarantees that:

-   Restarting containers does not delete data

-   Rebuilding images does not reset WordPress

-   System reboots do not affect content

If a container crashes, Docker automatically restarts it according to the restart policy, ensuring service continuity.