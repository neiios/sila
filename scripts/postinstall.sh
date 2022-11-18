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
    IFS=" " read -r -a packages <<<"$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $5}')"
    custom="$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $6}')"

    # install
    case "$format" in
      f) sudo -u "$username" flatpak install -y --noninteractive flathub "${packages[@]}" ;;
      a) sudo -u "$username" paru -S "${packages[@]}" --noconfrm --needed ;;
      p) pacman -S "${packages[@]}" --noconfirm --needed ;;
    esac

    # run optional custom postinstall command
    eval "$custom"
  done <<<"$choices"
}

# ask user for confirmation
whiptail --title "ALIS part 2" --yes-button "Continue" \
  --no-button "Cancel" \
  --yesno "Press \`Continue\` to run the postinstall script." 14 70 || {
  rm /root/.profile
  error "User exited."
}

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
# apps
installFromList "/root/alis/scripts/postinstall/csv/software.csv" "Select the applications you want to install:"
# gaming
installFromList "/root/alis/scripts/postinstall/csv/gaming.csv" "Select the applications you want to install:\n\nIf are a gamer you can install all of them just avoid duplicates."
# tweaks
# shellcheck source=/scripts/postinstall/tweaks.sh
source /root/alis/scripts/postinstall/tweaks.sh
# shellcheck source=/scripts/postinstall/dotfiles.sh
source /root/alis/scripts/postinstall/dotfiles.sh

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
