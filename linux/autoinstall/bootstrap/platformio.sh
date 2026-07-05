#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# Pipefail: Return the exit status of the last command in a pipe that failed.
# set -o

DEVUSER="jeff"

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
