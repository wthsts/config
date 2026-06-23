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

#cd ~/bootstrap/ansible
#ansible-playbook site.yml -c local
