#!/bin/bash


# Check if the first argument is empty
if [ -z "$1" ]; then
    echo "Error: Specify the destination directory as the first argument." >&2
    echo Note that to share drives with ubuntu vm, gui client must be logged in.
    echo They will show up under ~/shared_drives/ folder.
    exit 1
fi

echo "CIDATA destination is: $1"

# Assign variable without spaces around the =
ANSIBLE_DEST="$1/bootstrap/ansible"

# Always quote your variables to handle paths with spaces safely
mkdir -p "$ANSIBLE_DEST"

# Check exit code
if [ $? -ne 0 ]; then
    echo "Error: Failed to create $ANSIBLE_DEST directory." >&2
    exit 1
fi

cp -R autoinstall/* $1
if [ $? -ne 0 ]; then
    echo "Error: autoinstall directory copy failed." >&2
    exit 1
fi

cp -R ansible $1/bootstrap
if [ $? -ne 0 ]; then
    echo "Error: ansible directory copy failed" >&2
    exit 1
fi
