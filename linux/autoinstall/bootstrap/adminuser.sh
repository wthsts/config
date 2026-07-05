#!/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "This script must be NOT run as root (or with sudo)"
   exit 1
fi

sudo apt update
sudo apt install -y ansible

if [[ -f ~/bootstrap/authorized_keys ]]; then
    mkdir -p ~/.ssh

    if ! mv ~/bootstrap/authorized_keys ~/.ssh/authorized_keys ; then
      echo "ssh keys could not be moved to " ~/.ssh/authorized_keys
      exit 1
    fi
else
    echo "ssh already initialized"
fi

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chown $USER:$USER ~/.ssh
chown $USER:$USER ~/.ssh/*

# Ensure SSH is configured to deny password logins
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Ensure Pubkey authentication is enabled
sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH to apply changes
sudo systemctl restart ssh

#cd ~/bootstrap/ansible
#ansible-playbook site.yml -c local

# Install nftables and enable it to restict port access to the system.
# can view config afterwards with
#   sudo nft list ruleset
install -m 644 nftables.conf /etc/nftables.conf
systemctl enable --now nftables
systemctl reload nftables