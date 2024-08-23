Default deployment stack:
- Webserver: nginx
- Backend: Laravel
- Frontend: React (Vite)
- Database: MariaDB

Also supports Laravel queue and scheduler by default.

---------------------
0. setup github secrets:
- SSH_PRIVATE_KEY
- SSH_KNOWN_HOSTS
- SSH_USER
- SSH_HOST
- DEPLOY_PATH (/var/www/XXXX)

1. clone repo to the deployment server final destination
1.2. check github connection if repo is private!
2. setup enviromental variables for project (laravel and react)

3. Luo palvelimelle deployuser, jolla on sudo oikeudet. Aja myös sudo visudo komennolla tiedostoon no pass rivi ko. käyttäjälle.  (Dockerin käyttö voi vaatia deploy sh tiedostoon sudottamista)
 
4. Palvelimelta aseta SSH-asetukset pubkey only ja luo ssh-keygenillä avain (kvg jos et osaa)
 
5. Lisää githubissa secretsiin actionsissa avain SSH_PRIVATE_KEY ja aja palvelimen päässä: ssh-keyscan -H palvelimenip ja lisää komennon palaute avaimella SSH_KNOWN_HOSTS

Committaa kaikki muutokset pää/dev branchiin ajan tasalle ja kloonaa uusi branch nimellä staging

---------------

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

    Add the following line to the end of the file:

    ```bash
    deployuser ALL=(ALL) NOPASSWD
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

### 3. Setup SSH Access for `deployuser`

1. Log in as `deployuser` or switch to the `deployuser` account:

    ```bash
    su - deployuser
    ```

2. Create an `.ssh` directory and set the correct permissions:

    ```bash
    mkdir -p ~/.ssh &&
    chmod 700 ~/.ssh
    ```

3. Add your public SSH key to `deployuser`'s `authorized_keys`:

    If you already have an SSH key pair on your local machine, you can copy the public key to the server. Otherwise, generate a new SSH key pair using `ssh-keygen`.

    Copy the public key to the server:

    ```bash
    echo "your-public-ssh-key" >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
    ```

    Replace `your-public-ssh-key` with your actual public SSH key content.

### 4. Install Docker Compose

    Follow the official Docker Compose installation instructions:

### 5. Configure Firewall (Optional)

Ensure that your firewall allows SSH and any ports your application will use (e.g., HTTP/HTTPS):
   
### 6. Github Actions CI/CD pipeline

1. Copy contents of this repo to your actual project repository.
2. Clone your actual project repository to the deployment server (to the DEPLOY_PATH)
3. If you have private Github repo check #Private Github repo
4. Setup your .env variables

Make sure to add Guthub Secrets to the repo with your actual secrets:

- `SSH_PRIVATE_KEY`: Your private SSH key.
- `SSH_KNOWN_HOSTS`: Known hosts entries for SSH.
- `SSH_USER`: The deployment user, e.g., `deployuser`.
- `SSH_HOST`: Your server's hostname or IP address.
- `DEPLOY_PATH`: The path to your project on the server (/var/www/DEPLOY_PATH).

By following this guide, you'll set up a secure and automated CI/CD pipeline for your Laravel project using Docker and GitHub Actions.

## Private GitHub Repository

If you want to use a private GitHub repository directly from your server for CI/CD purposes, follow these steps to configure your server to use a Personal Access Token.

### 1. Create a Personal Access Token

1. Go to GitHub and navigate to **Account Settings**.
2. In the left sidebar, click on **Developer settings**.
3. Click on **Personal access tokens** and then **Generate new token**.
4. Give your token a descriptive name (e.g., `Deployment Token`).
5. Set an expiration date for the token (optional but recommended for security).
6. Select the `repo` scope (and any other necessary scopes) to ensure the token has access to private repositories.
7. Click on **Generate token**.
8. Copy the generated token. **Note:** You will not be able to see this token again, so save it in a secure place.

### 2. Add the Personal Access Token to the Server

1. **Log in to the server** via SSH using the `deployuser` or another appropriate user:

    ```bash
    ssh deployuser@your-server-ip
    ```

2. **Configure Git to use the Personal Access Token**:

    Modify the server's Git configuration to use the Personal Access Token automatically:

    ```bash
    git config --global credential.helper store
    ```

3. **Clone the repository using the Personal Access Token**:

    Use the following command to clone your GitHub repository using the Personal Access Token. This will save the token in the `git-credentials` file.

    ```bash
    git clone https://<your-token>@github.com/your-username/your-repo.git
    ```

    For example:

    ```bash
    git clone https://ghp_yourtoken1234567890@github.com/your-username/your-repo.git
    ```

    **Important:** Replace `ghp_yourtoken1234567890` with your actual Personal Access Token and `your-username/your-repo` with your GitHub username and repository name.

4. **Ensure the Personal Access Token is saved correctly**:

    Check the `~/.git-credentials` file to ensure the Personal Access Token is stored correctly. The content of the file should look something like this:

    ```plaintext
    https://ghp_yourtoken1234567890@github.com
    ```