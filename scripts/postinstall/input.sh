#!/bin/bash

username=$(whiptail --title "Username" --inputbox "Enter the username:" 0 0 3>&1 1>&2 2>&3)
password=$(whiptail --title "User password" --inputbox "Enter the password for your user:" 0 0 3>&1 1>&2 2>&3)

# drivers input
curl --create-dirs --output /tmp/input-drivers.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/drivers.sh && source /tmp/input-drivers.sh

# desktop input
curl --create-dirs --output /tmp/input-desktop.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/desktop.sh && source /tmp/input-desktop.sh

# software input
curl --create-dirs --output /tmp/input-software.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/software.sh && source /tmp/input-software.sh

# gaming input
curl --create-dirs --output /tmp/input-gaming.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/gaming.sh && source /tmp/input-gaming.sh

# fixes input
curl --create-dirs --output /tmp/input-fixes.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/fixes.sh && source /tmp/input-fixes.sh
