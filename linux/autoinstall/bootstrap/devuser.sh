#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# Pipefail: Return the exit status of the last command in a pipe that failed.
# set -o

USERNAME="jeff"

# Check if the user already exists
if sudo id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists. Skipping creation."
else
    echo "Creating user '$USERNAME'..."
    sudo useradd -m -s /bin/bash "$USERNAME"
fi

# Get the password field (the second field, separated by :)
# If the field starts with !, !!, or *, the account is locked/no password set
STATUS=$(sudo grep "^$USERNAME:" /etc/shadow | cut -d: -f2)

if [[ "$STATUS" == "!"* || "$STATUS" == "*" ]]; then
    echo "Password has NOT been set (account is locked)."
    sudo passwd "$USERNAME"
else
    echo "Password has been set."
fi

# Setup .ssh directory (this is naturally idempotent)
SSH_DIR="/home/$USERNAME/.ssh"
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"

# Create authorized_keys if it doesn't exist
AUTH_KEYS="$SSH_DIR/authorized_keys"
if [ ! -f "$AUTH_KEYS" ]; then
    sudo cp ~/.ssh/authorized_keys "$AUTH_KEYS"
    sudo chmod 600 "$AUTH_KEYS"
fi

# Enforce permissions (always safe to run)
sudo chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

echo "Updating packages and installing Podman..."
sudo apt-get update
sudo apt-get install -y podman

DEV_UID=$(id -u "$USERNAME")

# This tells systemd to keep the user's manager running even when not logged in
sudo loginctl enable-linger "$USERNAME"

# 3. Run the commands by forcing the environment variables inside the shell execution
#sudo -u "$USERNAME" XDG_RUNTIME_DIR="/run/user/$DEV_UID" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$DEV_UID/bus" systemctl --user enable podman.socket
#sudo -u "$USERNAME" XDG_RUNTIME_DIR="/run/user/$DEV_UID" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$DEV_UID/bus" systemctl --user start podman.socket

# 2. Enable and start the podman socket for the specific user
# Using --machine=<user>@.host handles the environment and bus connection automatically
sudo systemctl --user --machine="$USERNAME"@.host enable podman.socket
sudo systemctl --user --machine="$USERNAME"@.host start podman.socket