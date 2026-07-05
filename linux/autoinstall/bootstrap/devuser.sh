#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# Pipefail: Return the exit status of the last command in a pipe that failed.
# set -o

DEVUSER="jeff"

# Check if the user already exists
if sudo id "$DEVUSER" &>/dev/null; then
    echo "User '$DEVUSER' already exists. Skipping creation."
else
    echo "Creating user '$DEVUSER'..."
    sudo useradd -m -s /bin/bash "$DEVUSER"
fi

# Get the password field (the second field, separated by :)
# If the field starts with !, !!, or *, the account is locked/no password set
STATUS=$(sudo grep "^$DEVUSER:" /etc/shadow | cut -d: -f2)

if [[ "$STATUS" == "!"* || "$STATUS" == "*" ]]; then
    echo "Password has NOT been set (account is locked)."
    sudo passwd "$DEVUSER"
else
    echo "Password has been set."
fi

# Setup .ssh directory (this is naturally idempotent)
SSH_DIR="/home/$DEVUSER/.ssh"
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"

# Create authorized_keys if it doesn't exist
AUTH_KEYS="$SSH_DIR/authorized_keys"
if [ ! -f "$AUTH_KEYS" ]; then
    sudo cp ~/.ssh/authorized_keys "$AUTH_KEYS"
    sudo chmod 600 "$AUTH_KEYS"
fi

# Enforce permissions (always safe to run)
sudo chown -R "$DEVUSER:$DEVUSER" "$SSH_DIR"

DEVHOME="/home/$DEVUSER"
TARGET_FILE="$DEVHOME/.profile"

# Ensure the directory exists
sudo mkdir -p "$DEVHOME/bin"

# Add the path modification to .profile if it's not already there
if ! sudo grep -q "$DEVHOME/bin" "$TARGET_FILE"; then
  cat << 'EOF' | sudo tee -a "$TARGET_FILE" > /dev/null

# Added by bootstrap script
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export PATH
EOF
fi

# Perhaps this should be changed to a git project 
# located at ~/projects/tools/bin
#sudo cp devbin/* "$DEVHOME/bin"
#sudo chmod +x "$DEVHOME/bin"/*

echo "installing git needed for dev"
sudo apt install git

git config --global user.name "jeff"
git config --global user.email "jeffshagbaby@gmail.com"

echo "Updating packages and installing Podman..."
sudo apt-get update
sudo apt-get install -y podman

# This tells systemd to keep the user's manager running even when not logged in
sudo loginctl enable-linger "$DEVUSER"

# Enable and start the podman socket for the specific user
# Using --machine=<user>@.host handles the environment and bus connection automatically
sudo systemctl --user --machine="$DEVUSER"@.host enable podman.socket
sudo systemctl --user --machine="$DEVUSER"@.host start podman.socket

# Create a symbolic link so the system thinks 'docker' exists
# (Only if you don't have actual Docker installed)
sudo ln -sf /usr/bin/podman /usr/bin/docker
