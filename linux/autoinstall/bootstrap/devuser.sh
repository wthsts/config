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

echo "installing git needed for dev"
sudo apt install git

git config --global user.name "jeff"
git config --global user.email "jeffshagbaby@gmail.com"

DEV_UID=$(id -u "$DEVUSER")

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

# This is for platformio access to USB ports so code can be uploaded.
# Install the rules file (System-wide)
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules

# Apply the rules so the kernel picks them up immediately
sudo udevadm control --reload-rules
sudo udevadm trigger

# 3. Add the DEVUSER to the dialout group (The specific "Gatekeeper")
# Replace 'your_dev_username' with the actual account name of your dev user
sudo usermod -a -G dialout "$DEVUSER"

# This forces the device to be accessible by anyone in the 'dialout' group
#echo 'SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="dialout"' | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
# This forces the device mode to 0666, allowing anyone in the dialout group read/write access
echo 'KERNEL=="ttyUSB*", MODE="0666", GROUP="dialout"' | sudo tee /etc/udev/rules.d/99-platformio-udev.rules

# Reload
sudo udevadm control --reload-rules
sudo udevadm trigger
