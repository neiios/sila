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

# dotfiles
function cloneRepo() {
    # clone the repository
    while true; do
        # get the repository url ("" is important)
        l=""$(whiptail --title "Git repo link" --nocancel --inputbox "Enter the repository url without the https:// part:\n\nThe default value is github.com/richard96292/dotfiles.\nLeave the input empty to clone the default repository." 0 0 3>&1 1>&2 2>&3)
        # if the input is empty use the default value
        [[ -z "$l" ]] && git clone https://github.com/richard96292/dotfiles "/home/${username}/.dotfiles" && break
        # else clone the repo
        git clone "https://${l}" "/home/${username}/.dotfiles" && break
        # if we got to here the link is invalid
        whiptail --title "Error" --msgbox "The git repository doesn't exist. Verify the link and enter it again.\n\n" 0 0 || break
    done
}

function installDotfiles() {
  while true; do
    # remove directory if it exists
    [[ -d "/home/${username}/.dotfiles" ]] && rm -rf "/home/${username}/.dotfiles"
    cloneRepo
    # cd to it
    cd "/home/${username}/.dotfiles" || exit

    if [[ -e arch-install-dotfiles.sh ]]; then
      sudo -u "${username}" bash arch-install-dotfiles.sh && return
    else
      whiptail --title "Error" --yesno "The arch-install-dotfiles.sh script can't be found.\n\nCancel the dotfiles installation?" 0 0 && return
    fi
  done
}

if (whiptail --title "Dotfiles" --yesno "You can optionally install your dotfiles from a git repository.\n\nYou will need to enter the dotfile repository link.\n\nIt will search for arch-install-dotfiles.sh script in the root folder of the repository.\n\nDo you want to install the dotfiles?" 0 0); then
  installDotfiles
fi

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

# remove script autostart
sed -i '|^bash /root/alis|d' ~/.bashrc
