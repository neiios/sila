#!/usr/bin/env bash

set -e

function error() {
  echo "${1:-"Unknown Error"}" 1>&2
  exit 1
}

function tutorial() {
  # tutorial
  dialog --erase-on-exit \
    --title "Tutorial" \
    --msgbox "Up/Down arrows - navigate the list\nLeft/Right arrows or Tab - move to different parts of the dialog box\nEnter - confirm the dialog box\nSpace - toggle the selected item" 0 0
}

function getEncryptionPass() {
  while true; do
    encryptionPass=$(dialog --erase-on-exit \
      --nocancel \
      --title "Disk encryption password" \
      --insecure --passwordbox "${invalidPasswordMessage}Enter the disk encryption password:\nLeave the password blank if you dont want to encrypt the disk." 0 0 3>&1 1>&2 2>&3)
    [[ -n "$encryptionPass" ]] && encryptionPass2=$(dialog --erase-on-exit \
      --nocancel \
      --title "Disk encryption password" \
      --insecure --passwordbox "Retype the disk encryption password:" 0 0 3>&1 1>&2 2>&3)
    # passwords match and are not empty
    [[ "${encryptionPass}" == "${encryptionPass2}" && -n "${encryptionPass2}" ]] && {
      ENCRYPTION=1
      break
    }
    # password is empty
    [[ -z "$encryptionPass" ]] && break
    invalidPasswordMessage="The passwords did not match.\n\n"
  done
}

function selectDisk() {
  parts=()
  while read -r disk data; do
    parts+=("$disk" "$data")
  done < <(lsblk --nodeps -lno name,model,type,size | grep -v -e loop -e sr -e zram)
  selectedDisk="/dev/$(dialog --erase-on-exit --nocancel --title "WARNING: all data on the selected drive will be wiped" --menu "Choose the drive for the installation:" 0 0 0 "${parts[@]}" 3>&1 1>&2 2>&3)"

  # detect partition name template
  # not sure if mmcblk is needed (have no way to test it)
  t="$selectedDisk"
  if [[ "$t" =~ nvme|mmcblk ]]; then
    t+="p"
  fi
  bootPartition="${t}1"
  rootPartition="${t}2"
}

function partitionDisk() {
  # one last confirmation
  dialog --erase-on-exit --title "Here be dragons" \
    --defaultno --yes-button "Continue" --no-button "Cancel" \
    --yesno "All data on the disk $selectedDisk will be wiped.\nBe sure to double check the drive you have selected." 0 0 ||
    error "User exited."

  # point of no return
  # destroying the disk
  wipefs -af "$selectedDisk"

  # partition the disk
  if [[ $UEFI -eq 1 ]]; then
    sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:efi "$selectedDisk"
    sgdisk -n 0:0:0 -t 0:8300 -c 0:root "$selectedDisk"
    sgdisk -p "$selectedDisk"
  else
    echo -e 'size=512M\n size=+\n' | sfdisk --label dos "$selectedDisk"
  fi
}

function encryptDisk() {
  # encrypt root volume only if the password is given
  mappedRoot="$rootPartition"
  if [[ $ENCRYPTION -eq 1 ]]; then
    echo "$encryptionPass" | cryptsetup -q luksFormat "$rootPartition"
    echo "$encryptionPass" | cryptsetup open "$rootPartition" luks
    mappedRoot=/dev/mapper/luks
  fi
}

function formatDisk() {
  # format boot
  mkfs.vfat "$bootPartition"
  # format root partition
  mkfs.btrfs -f "$mappedRoot"
}

function createSubvolumes() {
  mount "$mappedRoot" /mnt
  btrfs sub create /mnt/@
  btrfs sub create /mnt/@home
  btrfs sub create /mnt/@log
  btrfs sub create /mnt/@pkg
  btrfs sub create /mnt/@snapshots
  umount -R /mnt
}

function mountSubvolumes() {
  mount -o noatime,compress-force=zstd,subvol=@ "$mappedRoot" /mnt
  # create mountpoints
  mount --mkdir -o noatime,compress-force=zstd,subvol=@home "$mappedRoot" /mnt/home
  mount --mkdir -o noatime,compress-force=zstd,subvol=@log "$mappedRoot" /mnt/var/log
  mount --mkdir -o noatime,compress-force=zstd,subvol=@pkg "$mappedRoot" /mnt/var/cache/pacman/pkg
  mount --mkdir -o noatime,compress-force=zstd,subvol=@snapshots "$mappedRoot" /mnt/.snapshots
  # boot/efi partition
  mount --mkdir "$bootPartition" /mnt/boot
}

function pacstrapSystem() {
  # install basic packages
  pacstrap /mnt base base-devel linux linux-headers linux-firmware dialog btrfs-progs
  # generate fstab
  genfstab -U /mnt >>/mnt/etc/fstab
  # transfer files
  cp -r /tmp/sila /mnt/root/sila

  # transfer variables to chroot
  cat <<EOF >/mnt/root/sila/scripts/vars.sh
selectedDisk="$selectedDisk"
rootPartition="$rootPartition"
mappedRoot="$mappedRoot"
UEFI="$UEFI"
ENCRYPTION="$ENCRYPTION"
EOF
}

function finalNotice() {
  if (dialog --erase-on-exit --title "Congratulations" \
    --yesno "The first part of the installation has finished succesfully.\n\nThe second part will start after reboot.\n\nDo you want to reboot your computer now?" 0 0); then
    dialog --erase-on-exit --title "Important" \
      --msgbox "You will have to log in as a root user after rebooting.\n\n" 0 0
    umount -R /mnt
    reboot
  fi
}

# misc
sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -i "s/^#VerbosePkgLists/VerbosePkgLists/" /etc/pacman.conf
sed -i "s/^#Color/Color/" /etc/pacman.conf
sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 10/" /etc/pacman.conf
reflector --save /etc/pacman.d/mirrorlist --country AU,BA,HR,FR,DE,IT,MC,RS,SI,CH, --protocol https --latest 10 --sort score
sleep 3

pacman -Sy dialog --noconfirm --needed
ls /sys/firmware/efi &>/dev/null && UEFI=1 || UEFI=0

# main
tutorial || error "User exited."

getEncryptionPass || error "Failed to get the disk encryption password."

selectDisk || error "Failed to select the disk."

partitionDisk || error "Failed to partition the disk."

encryptDisk || error "Failed to encrypt the disk."

formatDisk || error "Failed to format the disk."

createSubvolumes || error "Failed to create subvolumes."

mountSubvolumes || error "Failed to mount subvolumes or boot partition."

pacstrapSystem || error "Pacstrap failed."

arch-chroot /mnt /root/sila/scripts/2-archinstall.sh || error "Failed inside chroot."

finalNotice || error "User exited."
