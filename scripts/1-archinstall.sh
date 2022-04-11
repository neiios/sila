#!/usr/bin/env bash
set -xe
timedatectl set-ntp true

pacman -Syy
pacman -S dialog archlinux-keyring --noconfirm
# ----------------------------- inputs -----------------------------
parts=()
while read -r disk data; do
    parts+=("$disk" "$data")
done < <(lsblk --nodeps -lno name,model,type,size | grep -v -e loop -e sr)
exec 3>&1
diskname="/dev/$(dialog --menu "Choose one:" 0 0 0 "${parts[@]}" 2>&1 1>&3)"
exec 3>&-
clear
# not sure if mmcblk works
if [[ $diskname =~ nvme|mmcblk ]]; then
    literallyLetterP="p"
fi

exec 3>&1
hostname=$(dialog --inputbox "Enter the hostname for this computer:" 0 0 2>&1 1>&3)
exec 3>&-
clear

exec 3>&1
password=$(dialog --inputbox "Enter the password for the root user:" 0 0 2>&1 1>&3)
exec 3>&-
clear

exec 3>&1
passwordLuks=$(dialog --inputbox "Enter the password to encrypt the drive:" 0 0 2>&1 1>&3)
exec 3>&-
clear

optionsBootloader=(
    1 "systemd-boot"
    2 "GRUB (select if you want to dual boot)"
)
exec 3>&1
choiceBootloader=$(dialog --menu "Select the bootloader you want to use:" 0 0 0 "${optionsBootloader[@]}" 2>&1 1>&3)
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
# ----------------------------- inputs -----------------------------

# wiping existing partition and creating new ones
sgdisk --zap-all --clear ${diskname}
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:boot $diskname
sgdisk -n 0:0:0 -t 0:8300 -c 0:luks $diskname
sgdisk -p $diskname

# format boot
mkfs.vfat ${diskname}${literallyLetterP}1 -n EFI
# encrypt second partition
echo "${passwordLuks}" | cryptsetup -q luksFormat ${diskname}${literallyLetterP}2
echo "${passwordLuks}" | cryptsetup luksOpen ${diskname}${literallyLetterP}2 luks
# format partition
mkfs.btrfs /dev/mapper/luks -L root -f
# create subvolumes
mount /dev/mapper/luks /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
umount -R /mnt
# mount subvolumes
mount -o noatime,nodiratime,compress=zstd,subvol=@ /dev/mapper/luks /mnt
mkdir -pv /mnt/{boot,home}
mount -o noatime,nodiratime,compress=zstd,subvol=@home /dev/mapper/luks /mnt/home
# mount boot
mount ${diskname}${literallyLetterP}1 /mnt/boot

# install necessary packages
pacstrap /mnt base base-devel linux linux-headers linux-firmware git vim nano lvm2 networkmanager dialog efibootmgr btrfs-progs ${choiceCPU}-ucode
# generate fstab
genfstab -U /mnt >>/mnt/etc/fstab

curl --output /mnt/root/post-archinstall.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/post-archinstall.sh
curl --output /mnt/root/2-archinstall.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/2-archinstall.sh
sed -i "/set -xe/a hostname='${hostname}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a password='${password}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a diskname='${diskname}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a literallyLetterP='${literallyLetterP}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a choiceBootloader='${choiceBootloader}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a choiceCPU='${choiceCPU}'" /mnt/root/2-archinstall.sh
chmod +x /mnt/root/2-archinstall.sh

arch-chroot /mnt /root/2-archinstall.sh

rm /mnt/root/2-archinstall.sh

umount -R /mnt

dialog --title "Congratulations" --yes-label "Reboot" --no-label "Cancel" --yesno "First part of the installation has finished succesfully!\\n\\nDo you want to reboot your computer now?" 0 0
reboot
