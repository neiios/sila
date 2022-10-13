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
bash /root/alis/scripts/postinstall/input.sh
# basic packages
bash /root/alis/scripts/postinstall/basic-install.sh
# drivers
bash /root/alis/scripts/postinstall/drivers.sh
# desktops/wms
bash /root/alis/scripts/postinstall/desktop.sh
# fonts
bash /root/alis/scripts/postinstall/fonts.sh
# software
bash /root/alis/scripts/postinstall/software.sh
# gaming
bash /root/alis/scripts/postinstall/gaming.sh
# fixes
bash /root/alis/scripts/postinstall/fixes.sh

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
