This directory tree provides files to automate linux installation from a usb drive and no network access.
Currently one usb is used has the bootable linux distrobution and another is a fat32 formated drive with a CIDATA label that the linux installer will autoinstall by:
*    Mounting CIDATA usb as /mnt/cidata
*    Execute the user-data autoinstall instructions

After this install is complete the commands below needed to be manually executed:
*    cd /opt/bootstrap
*    sudo ./copydata.sh
*    sudo ./bootstrap.sh

If this bootstrap process is successful, the end result of all this is:
*    A temporary wifi connection to a guest network.
*    Addition of admin user with placeholder passwords.
*    Ansible installed.
*    System is ready for ansible with vault protection of passwords, kets etc to:
**     Complete linux install now that wifi is established.
**     Add ssh server and configure ssh public key access for dev user
**     Replace the guest wifi connection with isolated VLAN connection used for development
**     Change admin  password to something more secure.
**     Add dev user for software development with restricted access.
**     

