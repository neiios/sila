#!/usr/bin/env bash
set -e
timedatectl set-ntp true

# get user input
source /tmp/alis/scripts/1-archinstall/get-user-input.sh

# format and partition the drive
source /tmp/alis/scripts/1-archinstall/work-with-drives.sh

# install basic packages
pacstrap /mnt base base-devel linux linux-headers linux-firmware git vim libnewt btrfs-progs
# generate fstab
genfstab -U /mnt >>/mnt/etc/fstab

# transfer files
mv /tmp/alis /mnt/root/alis

# transfer variables to chroot
cat <<EOF >/mnt/root/alis/vars.sh
hostname="$hostname"
password="$password"
diskname="$diskname"
rootPartition="$rootPartition"
mappedRoot="$mappedRoot"
UEFIBIOS="$UEFIBIOS"
passwordLuks="$passwordLuks"
EOF

# chroot into the new install
arch-chroot /mnt /root/alis/scripts/2-archinstall.sh

# clean up
rm -rf /mnt/root/alis

# final notice
if (whiptail --title "Congratulations" --yesno "First part of the installation has finished succesfully.\n\nDo you want to reboot your computer now?" 0 0); then
  whiptail --title "Important!" --msgbox "You will have to log in as a root user after rebooting.\n\n" 0 0
  # unmount the drive before rebooting
  umount -R /mnt
  reboot
fi
