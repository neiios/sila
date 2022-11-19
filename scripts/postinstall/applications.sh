#!/bin/bash

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
  cmd=(whiptail --nocancel --separate-output --checklist "$2" 40 100 30)
  choices=$("${cmd[@]}" "${arr[@]}" 2>&1 >/dev/tty)
  clear

  [[ -z "${choices}" ]] && return

  # install loop
  while read -r app; do
    # get variables
    format="$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $1}')"
    IFS=" " read -r -a packages <<<"$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $5}')"
    custom="$(grep "${app}" /tmp/progs.csv | awk -F',' '{print $6}')"

    # install
    case "$format" in
      f) sudo -u "${username:?Username not set.}" flatpak install -y --noninteractive flathub "${packages[@]}" ;;
      a) sudo -u "${username:?Username not set.}" paru -S "${packages[@]}" --noconfirm --needed ;;
      p) pacman -S "${packages[@]}" --noconfirm --needed ;;
    esac

    # run optional custom postinstall command
    eval "$custom"
  done <<<"$choices"
}

# apps
installFromList "/root/alis/scripts/postinstall/csv/software.csv" "Select the applications you want to install:"
# gaming
installFromList "/root/alis/scripts/postinstall/csv/gaming.csv" "Select the applications you want to install:\n\nIf are a gamer you can install all of them just avoid duplicates."
