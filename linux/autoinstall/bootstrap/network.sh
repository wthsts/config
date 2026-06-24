#!/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "This script must be NOT run as root (or with sudo)"
   exit 1
fi

read -rp "SSID: " SSID
read -rp "WiFi Password: " PASS
echo

CONFIG_FILE=/etc/netplan/01-config.yaml

sudo tee $CONFIG_FILE <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    # Prevents 2 min of retrys when systm boots up by setting
    # optional to true for all ethernets that start with en*
    all-en-interfaces:
      match:
        name: "en*"
      dhcp4: true
      optional: true
  wifis:
    wlp2s0:
      dhcp4: true
      access-points:
        "$SSID":
          password: "$PASS"
EOF

sudo chmod 600 $CONFIG_FILE

if ! sudo netplan generate; then
    echo netplan generate failed.  Running again with --debug
    sudo netplan --debug generate
fi

if ! sudo netplan apply; then
    echo netplan apply failed.  Running again with --debug
    sudo netplan --debug apply
fi

SLEEP_TIME=10
echo "sleep $SLEEP_TIME before testing if the network is reachable"
sleep $SLEEP_TIME

if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
  echo "Intenet not reachable"
  exit 1
fi

if ! ping -c 1 archive.ubuntu.com >/dev/null 2>&1; then
  echo "DNS not working"
  exit 1
fi