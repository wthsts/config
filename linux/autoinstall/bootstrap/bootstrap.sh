echo "Detecting WiFi interface..."

IFACE=$(ip link | awk -F: '$0 ~ "wl" {print $2; exit}' | xargs)

if [ -z "$IFACE" ]; then
  echo "No WiFi interface found"
  exit 1
fi

echo "Using interface: $IFACE"

read -rp "SSID: " SSID
read -rp "WiFi Password: " PASS
echo

cat > /tmp/wpa.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="$SSID"
    psk="$PASS"
}
EOF

echo "Starting WiFi connection..."

wpa_supplicant -B -i "$IFACE" -c /tmp/wpa.conf

sleep 5

if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
  echo "Intenet not reachable"
  exit 1
fi

if ! ping -c 1 archive.ubuntu.com >/dev/null 2>&1; then
  echo "DNS not working"
  exit 1
fi

apt update
apt install -y ansible

#cd /opt/bootstrap/ansible
#ansible-playbook site.yml -c local
