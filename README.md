*This project has been created as part of the 42 curriculum by psantos-.*

* * * * *

**Description**


This project consists of deploying a complete web infrastructure using Docker Compose, designed to run a WordPress website backed by a MariaDB database, served via Nginx with HTTPS. The main objectives are to demonstrate:

-   **Service isolation**: Each component (WordPress, MariaDB, Nginx) is containerized in its own Docker container, ensuring that configuration, runtime, and dependencies are fully independent.

-   **Persistent data storage**: WordPress files and the database are stored in Docker volumes. This ensures that all content and configuration persist across container restarts or image rebuilds.

-   **Secure communication**: Nginx serves the WordPress site over HTTPS using a self-signed TLS certificate, demonstrating encryption and safe web access.

-   **Automation and reproducibility**: The project can be fully built and launched using a `Makefile` and Docker Compose, reducing manual setup errors and ensuring consistent results across systems.

-   **Best practices in containerization**: The Dockerfiles are built from the penultimate stable Debian version. No services run in the background in the entrypoints, avoiding common pitfalls that break container behavior in production.

The architecture consists of:

-   **Nginx**: Serves HTTPS traffic on port 443 only. It proxies PHP requests to the WordPress container over the internal Docker network.

-   **WordPress + PHP-FPM**: Handles the website's application logic. PHP-FPM listens on port 9000 internally for Nginx to connect.

-   **MariaDB**: Stores all WordPress data. Credentials are securely managed with Docker secrets.

The project demonstrates a real-world microservice approach, where services communicate securely and independently, yet persist data reliably.

* * * * *

**Directory Structure**

```
.
├── Makefile
├── secrets
│   ├── db_root_password.txt
│   ├── db_user_password.txt
│   └── wp_admin_password.txt
└── srcs
    ├── docker-compose.yml
    ├── .env
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   └── tools
        │       ├── 50-server.cnf
        │       └── entrypoint.sh
		|		└── init.sql
        ├── nginx
        │   ├── Dockerfile
        │   └── tools
        │       └── nginx.conf
        └── wordpress
            ├── Dockerfile
            └── tools
                └── entrypoint.sh
```

* * * * *

**Instructions**

These instruction use my user to setup the project, but you can change this to use your own domain.
Likewise with any other information (users, hosts, etc). Remember that in this case you must also change the information in the corresponding config files.
To set up and run the project, follow these steps:
<br><br>
0.  **Install Docker**<br><br>

This application was designed to run on a Linux machine.
To install Docker run the following commands:

Update packages and install verification tools
- Use `curl` to download Docker’s **GPG key**
- Use `gnupg` to **verify authenticity**
- Use `ca-certificates` to trust HTTPS
- Use `lsb-release` to pick the **correct repo**
```bash
#update packages
sudo apt update

#verification tools
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

install docker gpg key for package validation
```bash
#create directory for docker gpg key
sudo mkdir -p /etc/apt/keyrings

#download docker gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#read permission to everyone on this file
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

install docker 
```bash
#where to download Docker, architecture, and which GPG key to trust.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu jammy stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#update the packages again
sudo apt update

#installation of cli, daemon, compose
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Verify installation:
```bash
#check docker version
docker --version

#check docker compose version
docker compose version
```

add user to docker group
```bash
#adds user to docker group
sudo usermod -aG docker $USER

#starts new session with updated user groups
newgrp docker
```

Test
```bash
#should pull image from docker hub
docker run hello-world
```
<br><br>
1.  **Clone the repository**<br><br>

```bash
git clone <repo_url> my_project
cd my_project
```
<br><br>
2. **Prepare the Data directories and Domain Simulation**<br><br>

bind volumes live under:
```bash
/home/login/data
```

So on your machine, **simulate this**:
```bash
#create data directory in user home
mkdir /home/$USER/data/mariadb
mkdir /home/$USER/data/wordpress
```
Later your compose file should map volumes there (or use named volumes).

Your project domain:
```
login.42.fr
```

Locally, simulate this:
```bash
#local file that overrides dns resolution
sudo nano /etc/hosts
```

Add:
```bash
127.0.0.1 psantos-.42.fr
```
<br><br>
3.  **Prepare secrets and environment variables**<br><br>

You can inspect  the `.env` file (inside /srcs) and the `secrets` directory containing all required credentials:

```bash
secrets/db_root_password
secrets/db_user_password
secrets/wp_admin_password
```

The `.env` file should contain:

```bash
MYSQL_DB=wordpress
MYSQL_USER=wp_user #this is the database user besides host
MYSQL_HOST=mariadb
WP_ADMIN_USER=owner
WP_ADMIN_EMAIL=example@example.com
WP_URL=https://psantos-.42.fr
```
<br><br>
4.  **Build and launch all services**<br><br>

```bash
make
```

This command executes the `all` rule in the Makefile, which builds the Docker images for all services and starts them via Docker Compose.
<br><br>
5.  **Verify services**<br><br>

```bash
docker compose ps
docker volume ls
docker network ls
```

Confirm that all containers are running, volumes exist for persistence, and the Docker network allows inter-container communication.
<br><br>
6.  **Access the website**<br><br>

Open a browser and navigate to:

```bash
https://psantos-.42.fr
```

You should see the WordPress site fully installed, not the installation page. HTTP access (port 80) is blocked by design.
<br><br>
7.  **Administration panel**:<br><br>

    Access `/wp-admin` to log in as the administrator using the password in the secrets directory (in this case with user: owner, pw: inception).
<br><br>
8.  **Stop services**<br><br>

```bash
make down
```

This stops and removes the containers but preserves volumes and network for persistence.
<br><br>
9.  **Rebuild images without cache**<br><br>

```bash
make build
```

This is useful after modifying Dockerfiles or configuration.
<br><br>
10.  **Stop services and Delete images and Volumes**<br><br>

```bash
make clean
```

This stops and removes the containers and destroys volumes and images. Data persists in the bind mounted home/{user}/data/ directory

* * * * *

**Resources**


The following resources were used to develop and validate the project:

-   **Docker documentation**: Guides on building images, networking, volumes, and Docker Compose best practices.

-   **WordPress documentation**: Configuration guides for PHP-FPM, wp-cli, and database integration.

-   **MariaDB documentation**: Database initialization, user management, and secure password handling.

-   **Nginx documentation**: SSL/TLS configuration, reverse proxy setup, and PHP-FPM integration.

-   **Tutorials**: Online guides on containerized WordPress setups and persistent volume management.

**AI usage**: Assistance was used to generate explanations for configuration files, troubleshoot container startup issues, and draft example Dockerfiles and scripts. AI did not write the final configuration; all final code and setup decisions were made by the student.

* * * * *

**Project Design Choices**


The project emphasizes best practices in containerization:

-   **Docker vs Virtual Machines**:\
    Docker containers share the host kernel, making them lightweight and faster to start than full VMs, which emulate hardware. Unlike VMs, containers have lower resource overhead and easier portability.

-   **Secrets vs Environment Variables**:\
    Secrets are used for sensitive credentials such as passwords, ensuring they are not exposed in image layers or source code. Environment variables store configuration values that are safe to share, such as database names or site URLs.

-   **Docker Network vs Host Network**:\
    A custom bridge network (`srcs_inception`) allows containers to communicate by service name (e.g., `wordpress:9000`) while isolating them from the host. The host network would expose all container ports directly, which is less secure and reduces isolation.

-   **Docker Volumes vs Bind Mounts**:\
    Docker volumes are used for WordPress and MariaDB storage, providing portability, managed backups, and proper isolation from host filesystem changes. Bind mounts were avoided because they tie the container to a specific host path and can create permission issues.

* * * * *

**Additional Notes**


-   The project structure follows the `srcs` convention: all Dockerfiles, configuration files, and scripts are inside the `srcs` folder at the root.

-   The Makefile provides an easy interface for building, launching, stopping, and cleaning the stack.

-   All services are fully isolated, yet communicate over the bridge network with service names, ensuring modularity and maintainability.
