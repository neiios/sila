#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# vm check
# if [ $(dmesg | grep "Hypervisor detected" | wc -l) -ne 0 ]; then
#     echo "Virtual machine detected. Installing additional tools."
#     pacman -S qemu-guest-agent spice-vdagent virtualbox-guest-utils --noconfirm --needed
#     systemctl enable qemu-guest-agent.service
#     sleep 5
# fi

# install dependencies
pacman -Syyu libnewt git curl archlinux-keyring --noconfirm --needed

# use sudo without password (should be reverted at the end of the script)
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

# all inputs
curl --create-dirs --output /tmp/input.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/input.sh && source /tmp/input.sh

# basic packages
curl --create-dirs --output /tmp/basic-install.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/basic-install.sh && source /tmp/basic-install.sh

# drivers
curl --create-dirs --output /tmp/drivers.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/drivers.sh && source /tmp/drivers.sh

# desktops/wms
curl --create-dirs --output /tmp/desktop.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/desktop.sh && source /tmp/desktop.sh

# fonts
curl --create-dirs --output /tmp/fonts.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/fonts.sh && source /tmp/fonts.sh

# software
curl --create-dirs --output /tmp/software.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/software.sh && source /tmp/software.sh

# gaming
curl --create-dirs --output /tmp/gaming.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/gaming.sh && source /tmp/gaming.sh

# fixes
curl --create-dirs --output /tmp/fixes.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/postinstall/fixes.sh && source /tmp/fixes.sh

# fix permissions
chown -R ${username}:${username} /home/${username}

# revert sudoers file
sed -i "s/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

# one final update
pacman -Syu --noconfirm

rm -rf /root/post-archinstall.sh

# the most important step
pacman -S neofetch --noconfirm --needed
clear
neofetch
sleep 5

whiptail --title "Congratulations" --yesno "The installation has finished succesfully\!\n\nDo you want to reboot your computer now?" 0 0 && reboot
