#!/bin/bash

whiptail --title "Tutorial" --msgbox "Up/Down arrows - navigate the list\n\nLeft/Right arrows or Tab - move to different parts of the dialog box\n\nEnter - confirm the dialog box\n\nSpace - toggle the selected item" 0 0

# select the drive
parts=()
while read -r disk data; do
    parts+=("$disk" "$data")
done < <(lsblk --nodeps -lno name,model,type,size | grep -v -e loop -e sr)
diskname="/dev/$(whiptail --title "WARNING: all data on the selected drive will be wiped" --menu "Choose the drive for the installation:" 0 0 0 "${parts[@]}" 3>&1 1>&2 2>&3)"

# not sure if mmcblk works
if [[ $diskname =~ nvme|mmcblk ]]; then
    literallyLetterP="p"
fi

whiptail --title "Here be dragons" --yes-button "Continue" --no-button "Cancel" --yesno "All data on the disk ${diskname} will be wiped.\nBe sure to double check the drive you have selected." 0 0 || exit 1

function enterHostname() {
  while true; do
    h=$(whiptail --title "Hostname" --nocancel --inputbox "${invalidMessage}Enter the hostname for this computer:" 0 0 3>&1 1>&2 2>&3)
    [[ "${h}" =~ ^[a-zA-Z0-9]+(([a-zA-Z0-9-])*[a-zA-Z0-9]+)*$ ]] && echo "${h}" && break
    invalidMessage="The hostname is invalid.\nA valid hostname contains only letters from a to Z, numbers, and the hyphen (-).\nA hostname may not start or end with a hyphen.\n"
  done
}

hostname="$(enterHostname)"

function inputPass() {
    while true; do
        t=$(whiptail --title "$1 password" --passwordbox "${invalidPasswordMessage}Enter the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        t2=$(whiptail --title "$1 password" --passwordbox "Retype the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        [[ "${t}" == "${t2}" ]] && [[ -n "${t}" ]] && [[ -n "${t2}" ]] && echo "${t}" && break
        # special case for disk encryption (it can be an empty string)
        [[ "${t}" == "${t2}" ]] && [[ "$1" == "Disk encryption" ]] && echo "${t}" && break
        invalidPasswordMessage="The passwords did not match or you have entered an empty string.\n\n"
    done
}

password="$(inputPass "Root user")"
passwordLuks="$(inputPass "Disk encryption")"
