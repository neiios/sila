#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# use sudo without password (should be reverted at the end of the script)
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

# basic packages
bash /root/alis/scripts/postinstall/basic-install.sh
# drivers
bash /root/alis/scripts/postinstall/drivers.sh
# desktops
bash /root/alis/scripts/postinstall/desktop.sh
# software
bash /root/alis/scripts/postinstall/software.sh
# gaming
bash /root/alis/scripts/postinstall/gaming.sh
# tweaks
bash /root/alis/scripts/postinstall/tweaks.sh

# fix permissions
chown -R "${username}:${username}" "/home/${username}"

# revert sudoers file
sed -i "s/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

# one final update
pacman -Syu --noconfirm

# the most important step
pacman -S neofetch --noconfirm --needed
clear
neofetch
sleep 5
