#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

function error() {
  echo "${1:-"Unknown Error"}" 1>&2
  exit 1
}

# misc
# vm check
if [[ $(dmesg | grep "Hypervisor detected" -c) -ne 0 ]]; then
  echo "Virtual machine detected. Installing additional tools."
  pacman -S qemu-guest-agent spice-vdagent virtualbox-guest-utils --noconfirm --needed
  sleep 5
fi
pacman -S dialog --noconfirm --needed >/dev/null 2>&1

# ask user for confirmation
dialog --erase-on-exit --title "ALIS part 2" --yes-button "Continue" \
  --no-button "Cancel" \
  --yesno "Press 'Continue' to run the postinstall script." 8 40 || {
  rm /root/.profile
  error "User exited."
}

# use sudo without password (should be reverted at the end of the script)
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

# shellcheck source=/scripts/postinstall/basic-install.sh
source /root/alis/scripts/postinstall/basic-install.sh
cd "/home/${username}" || exit 1
# shellcheck source=/scripts/postinstall/drivers.sh
source /root/alis/scripts/postinstall/drivers.sh
# shellcheck source=/scripts/postinstall/desktop.sh
source /root/alis/scripts/postinstall/desktop.sh
# shellcheck source=/scripts/postinstall/applications.sh
source /root/alis/scripts/postinstall/applications.sh
# shellcheck source=/scripts/postinstall/tweaks.sh
source /root/alis/scripts/postinstall/tweaks.sh
# shellcheck source=/scripts/postinstall/dotfiles.sh
source /root/alis/scripts/postinstall/dotfiles.sh

# fix permissions
chown -R "${username}:${username}" "/home/${username}"

# revert sudoers file
sed -i "s/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

# the most important step
pacman -Syu neofetch --noconfirm --needed
clear
neofetch
sleep 5

# clean up
rm -rf "/root/.profile" "/root/alis" "/home/${username}/.npm"

# final notice
dialog --erase-on-exit \
  --title "Congratulations" \
  --yesno "The installation has finished succesfully.\n\nDo you want to reboot your computer now?" 0 0 \
  || error "User exited."
reboot
