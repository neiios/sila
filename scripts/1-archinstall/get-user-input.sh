#!/bin/bash

dialog --title "Tutorial" --yes-label "Ok" --no-label "Cancel" --yesno "Use:\nARROW KEYS to navigate this menu\nTAB to switch to the next item \nENTER to confirm the selection" 0 0

# select the drive
parts=()
while read -r disk data; do
    parts+=("$disk" "$data")
done < <(lsblk --nodeps -lno name,model,type,size | grep -v -e loop -e sr)
exec 3>&1
diskname="/dev/$(dialog --title "WARNING: all data on the selected drive will be wiped" --menu "Choose the drive for the installation:" 0 0 0 "${parts[@]}" 2>&1 1>&3)"
exec 3>&-
clear
# not sure if mmcblk works
if [[ $diskname =~ nvme|mmcblk ]]; then
    literallyLetterP="p"
fi

# select the hostname
exec 3>&1
hostname=$(dialog --inputbox "Enter the hostname for this computer:" 0 0 2>&1 1>&3)
exec 3>&-
clear

# select the root password
exec 3>&1
password=$(dialog --inputbox "Enter the password for the root user:" 0 0 2>&1 1>&3)
exec 3>&-
clear

# select encryption password
exec 3>&1
passwordLuks=$(dialog --title "Leave the input blank to not encrypt the drive" --inputbox "Enter the password to encrypt the drive:" 0 0 2>&1 1>&3)
exec 3>&-
clear

optionsManufacturer=(
    amd "AMD"
    intel "Intel"
)
exec 3>&1
choiceCPU=$(dialog --menu "Select your CPU manufacturer:" 0 0 0 "${optionsManufacturer[@]}" 2>&1 1>&3)
exec 3>&-
clear
