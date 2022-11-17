#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# use sudo without password (should be reverted at the end of the script)
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

function flatpakInstall() {
  sudo -u "$username" flatpak install -y --noninteractive flathub "${@}"
}

function paruInstall() {
  sudo -u "$username" paru -S "${@}" --noconfirm --needed
}

function pacmanInstall() {
  pacman -S "${@}" --noconfirm --needed
}

# first argument filepath, second whiptail string
function installFromList() {
  # remove lines that start with #
  sed '/^#/d' "$1" >/tmp/progs.csv

  # create package array from whiptail
  arr=()
  while IFS=, read -r format name desc state packages custom; do
    arr+=("$name")
    arr+=("$desc")
    arr+=("$state")
  done </tmp/progs.csv

  # run whiptail
  # TODO: check if selection is empty here
  cmd=(whiptail --nocancel --separate-output --checklist "$2" 32 156 24)
  choices=$("${cmd[@]}" "${arr[@]}" 2>&1 >/dev/tty)

  # install loop
  [[ -n $choices ]] && while read -r app; do
    # get variables
    format="$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $1}')"
    packages="$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $5}')"
    custom="$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $6}')"

    # install
    case "$format" in
    f) flatpakInstall ${packages} ;;
    a) paruInstall ${packages} ;;
    p) pacmanInstall ${packages} ;;
    esac

    # run optional custom postinstall command
    eval "$custom"
  done <<<"$choices"
}

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

    if [[ -e alis-install-dotfiles.sh ]]; then
      sudo -u "${username}" bash alis-install-dotfiles.sh && return
    else
      whiptail --title "Error" --yesno "The alis-install-dotfiles.sh script can't be found.\n\nCancel the dotfiles installation?" 0 0 && return
    fi
  done
}

# basic packages
# shellcheck source=/scripts/postinstall/basic-install.sh
source /root/alis/scripts/postinstall/basic-install.sh
# drivers
# shellcheck source=/scripts/postinstall/drivers.sh
source /root/alis/scripts/postinstall/drivers.sh
# desktops
# shellcheck source=/scripts/postinstall/desktop.sh
source /root/alis/scripts/postinstall/desktop.sh
# apps
installFromList "/root/alis/scripts/postinstall/csv/software.csv" "Select the applications you want to install:"
# gaming
installFromList "/root/alis/scripts/postinstall/csv/gaming.csv" "Select the applications you want to install:\n\nIf are a gamer you can install all of them just avoid duplicates."
# tweaks
# shellcheck source=/scripts/postinstall/tweaks.sh
source /root/alis/scripts/postinstall/tweaks.sh

# dotfiles
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

# dont autostart
rm /root/.profile

# clean up
rm -rf /mnt/root/alis

# final notice
whiptail --title "Congratulations" --yesno "The installation has finished succesfully.\n\nDo you want to reboot your computer now?" 0 0 && reboot
