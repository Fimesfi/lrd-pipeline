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

- ohjeet miten dockeria hallintaa
- miten mennään containerin bashiin
- jne

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
    ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
    ```

    - When prompted, save the key to a specific file (e.g., `~/.ssh/id_rsa_deploy`).
    - Leave the passphrase empty unless you have a specific reason to use one.

2. **Copy the Private Key**:

    Use the following command to display the contents of the private key file (e.g., `id_rsa_deploy`):

    ```bash
    cat ~/.ssh/id_rsa_deploy
    ```

    Copy the entire content of the private key file.

3. **Add the Private Key to GitHub Secrets**:

    - Go to your GitHub repository on the GitHub website.
    - Click on **Settings** in the repository.
    - In the left sidebar, click on **Secrets** under the **Security** section.
    - Click on **New repository secret**.
    - Name the secret `SSH_PRIVATE_KEY`.
    - Paste the copied private key into the value field.
    - Click **Add secret** to save.

4. **Add known hosts key**

    - Run `ssh-keyscan -H <server-ip>` on server
    - Copy public key and add it to repository Github Secrets

### 4. Install Docker Compose

    Follow the official Docker Compose installation instructions:

### 5. Configure Firewall (Optional)

Ensure that your firewall allows SSH and any ports your application will use (e.g., HTTP/HTTPS):
   
### 6. Github Actions CI/CD pipeline

1. Copy contents of this repo to your actual project repository.
2. Clone your actual project repository to the deployment server (to the DEPLOY_PATH)
3. If you have private Github repo check #Private Github repo (make sure to use SSH clone)
4. Setup your .env variables
5. Run `composer install`

Make sure to add Guthub Secrets to the repo with your actual secrets:

- `SSH_PRIVATE_KEY`: Your private SSH key.
- `SSH_KNOWN_HOSTS`: Known hosts entries for SSH.
- `SSH_USER`: The deployment user, e.g., `deployuser`.
- `SSH_HOST`: Your server's hostname or IP address.
- `DEPLOY_PATH`: The path to your project on the server (/var/www/DEPLOY_PATH).

By following this guide, you'll set up a secure and automated CI/CD pipeline for your Laravel project using Docker and GitHub Actions.

## Private GitHub Repository

If you want to use a private GitHub repository directly from your server for CI/CD purposes, you can set up a repository-specific deploy key using SSH. Follow these steps to configure your server.

### 1. Generate an SSH Key Pair on Your Server

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