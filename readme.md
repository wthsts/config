This directory tree provides files to automate ubuntu server installation from a usb drive and no network access.
Currently one usb is used has the bootable linux distrobution and another is a fat32 formated drive with a CIDATA label that the linux installer will autoinstall by:
*    Mounting CIDATA usb as /mnt/cidata
*    Execute the user-data autoinstall which includes late-commands
**     Creates admin user with temporary password because although it is encrypted, it is stored in autoinstaller user-data file which is in git.
**     This removes installer /etc/netplan/ yaml file and replaces it with one that makes ethernet port optional to avoid 2min retries when system is booted
**     Copies bootstrap files in ~/bootstrap
**     I don't create a systemd to run my bootstrap scripts because I will e physically at the machine, wifi ssid and password must be prompted, and stuff goes wrong sometimes.

After this install is complete the commands below needed to be manually executed on the physical machine:
*    cd /opt/bootstrap
*    Execite "sudo ./network.sh" to establish wifi network and keep ethernet port optional using /etc/netplan yaml file.
*    Execute "sudo ./bootstrap.sh" to set up ~/.ssh folder for admin user so I can ssh to the machine.  Set PasswordAuthentication to no in sshd config.

If this bootstrap process is successful, the end result of all this is:
*   A wifi connection with ethernet port disabled to avoid 2 min retries accessing that port.
*   Addition of admin user.
*   ssh server started and ~/.ssh folder with authorized public keys for admin user.
*   
*    Ansible installed.
*    System is ready for ansible with vault protection of passwords, kets etc to:
**     Add dev user for software development with restricted access.
**     

Podmand and DevContainer notes

I had trouble getting Microsoft ContainerTools extension tools working so I uninstalled them
and just work with the DevContainer extension.
