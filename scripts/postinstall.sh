#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# use sudo without password (should be reverted at the end of the script)
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

# basic packages
# shellcheck source=/scripts/postinstall/basic-install.sh
source /root/alis/scripts/postinstall/basic-install.sh
# drivers
# shellcheck source=/scripts/postinstall/drivers.sh
source /root/alis/scripts/postinstall/drivers.sh
# desktops
# shellcheck source=/scripts/postinstall/desktop.sh
source /root/alis/scripts/postinstall/desktop.sh
# software
# shellcheck source=/scripts/postinstall/software.sh
source /root/alis/scripts/postinstall/software.sh
# gaming
# shellcheck source=/scripts/postinstall/gaming.sh
source /root/alis/scripts/postinstall/gaming.sh
# tweaks
# shellcheck source=/scripts/postinstall/tweaks.sh
source /root/alis/scripts/postinstall/tweaks.sh

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
