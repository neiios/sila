#!/usr/bin/env bash
set -e
timedatectl set-ntp true

# functions
function inputPass() {
    while true; do
        [[ "$1" == "Disk encryption" ]] && encryptExplanation="\nLeave the password blank if you dont want to encrypt the disk."
        t=$(whiptail --title "$1 password" --nocancel --passwordbox "${invalidPasswordMessage}Enter the $1 password:${encryptExplanation}" --nocancel 10 50 3>&1 1>&2 2>&3)
        [[ -n "${t}" ]] && t2=$(whiptail --title "$1 password" --nocancel --passwordbox "Retype the $1 password:${encryptExplanation}" --nocancel 10 50 3>&1 1>&2 2>&3)
        [[ "${t}" == "${t2}" && -n "${t}" && -n "${t2}" ]] && echo "${t}" && break
        # special case for disk encryption (it can be an empty string)
        [[ -z "${t}" && "$1" == "Disk encryption" ]] && echo "${t}" && break
        invalidPasswordMessage="The passwords did not match or you have entered an empty string.\n\n"
    done
}

# tutorial
whiptail --title "Tutorial" --msgbox "Up/Down arrows - navigate the list\n\nLeft/Right arrows or Tab - move to different parts of the dialog box\n\nEnter - confirm the dialog box\n\nSpace - toggle the selected item" 0 0
clear

# both passwords (luks can be empty)
password="$(inputPass "Root user")"
passwordLuks="$(inputPass "Disk encryption")"

# select the drive 
parts=()
while read -r disk data; do
    parts+=("$disk" "$data")
done < <(lsblk --nodeps -lno name,model,type,size | grep -v -e loop -e sr)
diskname="/dev/$(whiptail --title "WARNING: all data on the selected drive will be wiped" --menu "Choose the drive for the installation:" 0 0 0 "${parts[@]}" 3>&1 1>&2 2>&3)"

# point of no return
whiptail --title "Here be dragons" --yes-button "Continue" --no-button "Cancel" --yesno "All data on the disk ${diskname} will be wiped.\nBe sure to double check the drive you have selected." 0 0 || exit 1
clear

# destroying the drive
wipefs -af "${diskname}"

# uefi check
ls /sys/firmware/efi &>/dev/null && UEFIBIOS=1 || UEFIBIOS=0

# partition the drive
if [[ $UEFIBIOS -eq 1 ]]; then
    # UEFI
    sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:efi "${diskname}"
    sgdisk -n 0:0:0 -t 0:8300 -c 0:root "${diskname}"
    sgdisk -p "${diskname}"
else
    # BIOS
    echo -e 'size=512M\n size=+\n' | sfdisk --label dos "${diskname}"
fi

# not sure if mmcblk is needed (cant test it)
t="$diskname"
if [[ "$t" =~ nvme|mmcblk ]]; then
  t+="p"
fi
bootPartition="${t}1"
rootPartition="${t}2"

# format boot
mkfs.vfat "${bootPartition}"

# encrypt root volume if password is given
if [[ -n ${passwordLuks} ]]; then 
  echo "${passwordLuks}" | cryptsetup -q luksFormat "$rootPartition"
  echo "${passwordLuks}" | cryptsetup open "$rootPartition" luks
  mappedRoot=/dev/mapper/luks
else
  mappedRoot="$rootPartition"
fi

# format root partition
mkfs.btrfs "${mappedRoot}"

# create subvolumes
mount "${mappedRoot}" /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@log
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@snapshots
umount -R /mnt

# mount subvolumes
mount -o noatime,compress-force=zstd,subvol=@ "${mappedRoot}" /mnt
mkdir -pv /mnt/{boot,home,var/log,var/cache/pacman/pkg,.snapshots}
mount -o noatime,compress-force=zstd,subvol=@home "${mappedRoot}" /mnt/home
mount -o noatime,compress-force=zstd,subvol=@log "${mappedRoot}" /mnt/var/log
mount -o noatime,compress-force=zstd,subvol=@pkg "${mappedRoot}" /mnt/var/cache/pacman/pkg
mount -o noatime,compress-force=zstd,subvol=@snapshots "${mappedRoot}" /mnt/.snapshots

# mount boot
mount "${bootPartition}" /mnt/boot
# install basic packages
pacstrap /mnt base base-devel linux linux-headers linux-firmware git vim libnewt btrfs-progs
# generate fstab
genfstab -U /mnt >>/mnt/etc/fstab

# transfer files
mv /tmp/alis /mnt/root/alis

# transfer variables to chroot
cat <<EOF >/mnt/root/alis/scripts/vars.sh
password="$password"
diskname="$diskname"
rootPartition="$rootPartition"
mappedRoot="$mappedRoot"
UEFIBIOS="$UEFIBIOS"
passwordLuks="$passwordLuks"
EOF

# chroot into the new install
mount -t proc /proc /mnt/proc/
mount -t sysfs /sys /mnt/sys/
mount --rbind /dev /mnt/dev/
[[ $UEFIBIOS -eq 1 ]] && mount --rbind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
cp /etc/resolv.conf /mnt/etc/resolv.conf
chroot /mnt /root/alis/scripts/2-archinstall.sh

# final notice
if (whiptail --title "Congratulations" --yesno "The first part of the installation has finished succesfully.\n\nThe second part will start after reboot.\n\nDo you want to reboot your computer now?" 0 0); then
  whiptail --title "Important!" --msgbox "You will have to log in as a root user after rebooting.\n\n" 0 0
  # unmount the drive before rebooting
  umount -R /mnt
  reboot
fi
