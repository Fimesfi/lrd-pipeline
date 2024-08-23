# LRD CI/CD Pipeline

Laravel, React, and Docker production project deployment stack for easy and secure application deployment on each pull request. Also includes a web server proxy.

Default deployment stack:
- Webserver: Nginx/Apache2 (uses Nginx as proxy)
- Backend: Laravel
- Frontend: React (Vite)
- Database: MariaDB
- SSL certs: Certbot

Also supports Laravel queue by default.

### Authors:

- Eeli Grén (Fimes)
- Joni Niemelä

# CI/CD Deployment Pipeline Setup

This guide explains how to set up a deployment server for a Laravel project using Docker and GitHub Actions.

## Prerequisites

- An Ubuntu server (for example, on AWS, DigitalOcean, or any cloud provider).
- SSH access to the server.
- Git
- GitHub repository with your Laravel & React project.

## Setup Deployment Server

In this example, we use Ubuntu.

### 1. Install Docker

Follow the official Docker installation instructions for Ubuntu:

[Docker installation guide for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

### 2. Create a Deployment User

1. **Create a new user called `deployuser`:**

   Log in to your server with SSH as the root user or a user with sudo privileges.

    ```bash
    sudo adduser deployuser
    ```

    Set a password for `deployuser` when prompted. You can skip the optional information fields by pressing Enter.

2. Add `deployuser` to the `sudo` group:

    This grants `deployuser` the ability to run commands with `sudo`.

    ```bash
    sudo usermod -aG sudo deployuser
    ```
3. Allow `deployuser` to run `sudo` commands without a password:

    Edit the sudoers file to grant passwordless sudo access to `deployuser`:

    ```bash
    sudo visudo
    ```

    Add the following line to the **end** of the file:

    ```bash
    deployuser ALL=(ALL) NOPASSWD: ALL
    ```

4. Verify `deployuser` can use `sudo` without a password:

    Log in as `deployuser` or switch to the `deployuser` account:

    ```bash
    su - deployuser
    ```

    Run a command using `sudo` to verify that no password prompt appears:

    ```bash
    sudo ls -la /root
    ```

### 3. Add the Private Key to GitHub Secrets

To allow GitHub Actions to access your server securely, you need to add the private SSH key to GitHub Secrets. This private key should match the public key added to the server in the previous step.

1. **Generate an SSH Key Pair** (if you haven't already):

    On your local machine or directly on the server, generate an SSH key pair if you don't have one:

    ```bash
    sudo ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
    ```

    - When prompted, save the key to a specific file (e.g., `~/.ssh/id_rsa_deploy`).
    - Leave the passphrase empty unless you have a specific reason to use one.

2. **Authorize the Public Key on the Server**

    ```bash
    sudo cat ~/.ssh/id_rsa_deploy.pub >> ~/.ssh/authorized_keys
    ```

    ```bash
    sudo chmod 700 ~/.ssh &&
    sudo chmod 600 ~/.ssh/authorized_keys &&
    sudo chmod 600 ~/.ssh/id_rsa_deploy
    ```

3. **Copy the Private Key**:

    Use the following command to display the contents of the private key file (e.g., `id_rsa_deploy`):

    ```bash
    cat ~/.ssh/id_rsa_deploy
    ```

    Copy the entire content of the private key file.

4. **Add the Private Key to GitHub Secrets**:

    - Go to your GitHub repository on the GitHub website.
    - Click on **Settings** in the repository.
    - In the left sidebar, click on **Secrets** under the **Security** section.
    - Click on **New repository secret**.
    - Name the secret `SSH_PRIVATE_KEY`.
    - Paste the copied private key into the value field.
    - Click **Add secret** to save.

5. **Add known hosts key**

    - Run `ssh-keyscan -H <server-ip>` on server
    - Copy public key and add it to repository Github Secrets

### 4. Install Docker Compose

    Follow the official Docker Compose installation instructions:

### 5. Configure Firewall (Optional)

Ensure that your firewall allows SSH and any ports your application will use (e.g., HTTP/HTTPS):
   
### 6. Github Actions CI/CD pipeline

1. Copy contents of this repo to your actual project repository.
2. Change YOURDOMAIN.COM on every this repo file to your actual domains.
2. Clone your actual project repository to the deployment server (to the DEPLOY_PATH)
3. If you have private Github repo check "Private GitHub Repository" (make sure to use SSH clone command than http)
4. Setup your .env variables
5. Run `composer install`

Make sure to add Guthub Secrets to the repo with your actual secrets:

- `SSH_PRIVATE_KEY`: Your private SSH key.
- `SSH_KNOWN_HOSTS`: Known hosts entries for SSH.
- `SSH_USER`: The deployment user, e.g., `deployuser`.
- `SSH_HOST`: Your server's hostname or IP address.
- `DEPLOY_PATH`: The path to your project on the server (/var/www/DEPLOY_PATH).

By following this guide, you'll set up a secure and automated CI/CD pipeline for your LRD stack project using Docker and GitHub Actions.

## SSL certificates

There is two nginx.conf files provided.

Run this one-time command for each domain in use to generate certs after composer is running.

To start composer in command line run `sudo composer up -d --build`

```bash
sudo docker run -it --rm --name certbot \
    -v $(pwd)/etc/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/var/www/html:/var/www/html \
    certbot/certbot certonly --webroot \
    --webroot-path=/var/www/html \
    -d YOURDOMAIN.FI -v
```

After that you can rename ssl_nginx.conf back to nginx.conf (remeber to check the config) and you are good to go!

## Private GitHub Repository

If you want to use a private GitHub repository directly from your server for CI/CD purposes, you can set up a repository-specific deploy key using SSH. Follow these steps to configure your server.

### 1. Generate an SSH Key Pair on Your Server

**IMPORTANT!** If you already created key called "id_rsa_deploy" in previous steps you can use that same key, just skip to the 1.3. step!

1. **Log in to your server** via SSH using the `deployuser` or another appropriate user:

    ```bash
    ssh deployuser@your-server-ip
    ```

2. **Generate a new SSH key pair**:

    Run the following command to generate a new SSH key pair. Use a descriptive name for the key, such as `id_rsa_deploy`:

    ```bash
    ssh-keygen -t rsa -b 4096 -C "deploy key for your-repo" -f ~/.ssh/id_rsa_deploy
    ```

    - Press Enter to accept the default file location.
    - You can set a passphrase for the key for additional security, but it’s optional. If you set a passphrase, you'll need to provide it every time the key is used.

3. **Copy the public key to the clipboard**:

    Use the following command to display the contents of the public key. You will copy this and add it to GitHub as a deploy key.

    ```bash
    cat ~/.ssh/id_rsa_deploy.pub
    ```

### 2. Add the Deploy Key to Your GitHub Repository

1. Go to your GitHub repository where you want to set up the deploy key.
2. Click on **Settings** in the repository.
3. In the left sidebar, click on **Deploy keys**.
4. Click on **Add deploy key**.
5. Provide a title for the key (e.g., `Deploy Key for CI/CD`).
6. Paste the public key (the contents of `id_rsa_deploy.pub`) into the **Key** field.
7. Check the box labeled **Allow write access** if you want the server to push changes back to the repository. This is optional; usually, read-only access is sufficient for deployments.
8. Click **Add key** to save the deploy key.

### 3. Configure SSH on Your Server

1. **Ensure SSH is configured to use the deploy key**:

    Create or edit the SSH configuration file (`~/.ssh/config`) to specify that SSH should use this deploy key for connections to GitHub.

    Open the SSH config file:

    ```bash
    nano ~/.ssh/config
    ```

    Add the following configuration:

    ```plaintext
    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_rsa_deploy
      IdentitiesOnly yes
    ```

    This configuration tells SSH to use the `id_rsa_deploy` key when connecting to `github.com`.

2. **Set the correct permissions for the SSH key and config file**:

    ```bash
    chmod 600 ~/.ssh/id_rsa_deploy &&
    chmod 644 ~/.ssh/id_rsa_deploy.pub &&
    chmod 600 ~/.ssh/config
    ```

### 4. Test the SSH Connection to GitHub

Run the following command to test that the server can connect to GitHub using the deploy key:

```bash
ssh -T git@github.com
```

## Troubleshooting & tips

- Create Docker volume for database `sudo docker volume create mariadb_data`
- Make sure that ports 80, 443 or 3306 are not in use on same host!
- If database have a problems make sure that you have configured DB_DATABASE and DB_PASSWORD in .env to actual values!

### Basic Docker Commands

#### Accessing a Docker Container's Command Line

To access the command line of a running Docker container, use the `docker exec` command. This is useful for troubleshooting, running commands inside the container, or exploring the container's environment.

```bash
sudo docker exec -it <container_name> /bin/bash
```

- Replace `<container_name>` with the name or ID of the container you want to access.
- The `/bin/bash` part specifies that you want to open a Bash shell. If Bash is not available, you can use `/bin/sh`.

Example:

```bash
sudo docker exec -it laravel-www /bin/bash
```

This command opens a Bash shell inside the `laravel-www` container.

#### Full Rebuild of Docker Containers

If you need to rebuild the Docker containers from scratch (e.g., after changing dependencies or configuration files), you can use the following commands:

```bash
sudo docker compose down --rmi all --volumes --remove-orphans
sudo docker compose up -d --build
```

- `docker compose down --rmi all --volumes --remove-orphans`: Stops and removes containers, networks, volumes, and images created by `up`.
  - `--rmi all`: Removes all images used by any service.
  - `--volumes`: Removes all volumes associated with the containers.
  - `--remove-orphans`: Removes containers for services not defined in the `docker-compose.yml`.

- `docker compose up -d --build`: Rebuilds and starts the containers in the background.
  - `-d`: Run containers in the background (detached mode).
  - `--build`: Build images before starting containers.

#### Viewing Container Logs

To view the logs of a running container, use the `docker logs` command. This is helpful for debugging and monitoring the behavior of your applications.

```bash
sudo docker logs <container_name>
```

- Replace `<container_name>` with the name or ID of the container whose logs you want to view.

Example:

```bash
sudo docker logs laravel-www
```

- To follow the logs in real-time (like `tail -f`), use the `-f` flag:

  ```bash
  sudo docker logs -f laravel-www
  ```

#### Additional Useful Commands

- **List All Running Containers**: To see a list of all currently running containers, use:

  ```bash
  sudo docker ps
  ```

- **List All Containers (Including Stopped)**: To list all containers, running or stopped:

  ```bash
  sudo docker ps -a
  ```

- **Stop a Running Container**: To stop a specific container:

  ```bash
  sudo docker stop <container_name>
  ```

- **Remove a Stopped Container**: To remove a container that is no longer running:

  ```bash
  sudo docker rm <container_name>
  ```

- **Remove Unused Images, Containers, Volumes, and Networks**: To clean up resources not associated with a running container, use:

  ```bash
  sudo docker system prune -a
  ```

  - `-a`: Removes all unused images, not just dangling ones.

### Summary

- Use `docker exec -it <container_name> /bin/bash` to access a container's shell.
- Use `docker compose down --rmi all --volumes --remove-orphans` followed by `docker compose up -d --build` for a full rebuild.
- Use `docker logs <container_name>` to view container logs.
- Use other commands for managing and cleaning up Docker resources.

These commands will help you efficiently manage your Docker environment, troubleshoot issues, and ensure your containers are running smoothly.
