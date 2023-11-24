#!/bin/bash

# first argument filepath, second dialog string
function installFromList() {
  TMPFILE="$(mktemp)"
  # remove lines that start with #
  sed '/^#/d' "$1" >"${TMPFILE}"

  # create package array from dialog
  arr=()
  while IFS=, read -r format name desc state packages custom; do
    arr+=("$name" "$desc" "$state")
  done <"${TMPFILE}"

  # run dialog
  cmd=(dialog --erase-on-exit --stdout --separate-output --nocancel
    --title "Packages"
    --checklist "$2" 22 76 16)
  choices=$("${cmd[@]}" "${arr[@]}")

  [[ -z "${choices}" ]] && return

  # install loop
  for app in $choices; do
    # get variables
    format="$(grep "${app}" "${TMPFILE}" | awk -F',' '{print $1}')"
    IFS=" " read -r -a packages <<<"$(grep "${app}" "${TMPFILE}" | awk -F',' '{print $5}')"
    custom="$(grep "${app}" "${TMPFILE}" | awk -F',' '{print $6}')"

    # install
    case "$format" in
      f) flatpak install -y --noninteractive --system flathub "${packages[@]}" ;;
      a) sudo -u "${username:?Username not set.}" paru -S "${packages[@]}" --noconfirm --needed ;;
      p) pacman -S "${packages[@]}" --noconfirm --needed ;;
    esac

    # run optional custom postinstall command
    eval "$custom"
  done
}
# apps
installFromList "/root/sila/scripts/postinstall/csv/software.csv" "Select the applications you want to install:"
# gaming
installFromList "/root/sila/scripts/postinstall/csv/gaming.csv" "Select the applications you want to install:\n\nIf are a gamer you can install all of them just avoid duplicates."
# development
installFromList "/root/sila/scripts/postinstall/csv/development.csv" "Select the applications you want to install:"