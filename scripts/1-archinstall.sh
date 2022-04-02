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

options=(
    1 "Ext4 (Recommended)"
    2 "Btrfs (NOT SUPPORTED)"
)
exec 3>&1
choice=$(dialog --menu "Select the file system type you want to use:" 0 0 0 "${options[@]}" 2>&1 1>&3)
exec 3>&-
clear

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
# ----------------------------- inputs -----------------------------

# wiping existing partition and creating new ones
sgdisk --zap-all --clear ${diskname}
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:boot $diskname
sgdisk -n 0:0:0 -t 0:8300 -c 0:luks $diskname
sgdisk -p $diskname

case $choice in
*)
    # format boot
    mkfs.vfat ${diskname}${literallyLetterP}1 -n BOOT
    # encrypt second partition
    echo "${passwordLuks}" | cryptsetup -q luksFormat ${diskname}${literallyLetterP}2
    echo "${passwordLuks}" | cryptsetup luksOpen ${diskname}${literallyLetterP}2 luks
    # configure lvm
    pvcreate /dev/mapper/luks
    vgcreate vg0 /dev/mapper/luks
    # create logical volumes
    lvcreate -L 128G vg0 -n root
    lvcreate -l 100%FREE vg0 -n home
    # format partitions
    mkfs.ext4 -L root /dev/mapper/vg0-root
    mkfs.ext4 -L home /dev/mapper/vg0-home
    # mount partitions
    mount /dev/mapper/vg0-root /mnt
    mkdir -pv /mnt/{boot,home}
    mount ${diskname}${literallyLetterP}1 /mnt/boot
    mount /dev/mapper/vg0-home /mnt/home
    ;;
    # 2)
    #     # NOTE: genfstab creates both subvolid and subvol (this fucks timeshift up)
    #     # NOTE: space_cache doesn't work not sure what the reason is (space_cache=v2 does work)

    #     mkfs.vfat ${diskname}1 -n boot
    #     mkfs.btrfs ${diskname}2 -L root -f

    #     mount ${diskname}2 /mnt
    #     cd /mnt
    #     btrfs subvolume create @
    #     btrfs subvolume create @home
    #     btrfs subvolume create @var
    #     cd /root
    #     umount -R /mnt
    #     echo "Subvolumes created"

    #     mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ ${diskname}2 /mnt
    #     mkdir -pv /mnt/{boot,home,var}
    #     mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@home ${diskname}2 /mnt/home
    #     mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@var ${diskname}2 /mnt/var
    #     mount ${diskname}1 /mnt/boot
    #     btrfsPackages=btrfs-progs
    #     ;;
esac

# install necessary packages
pacstrap /mnt base base-devel linux linux-headers linux-firmware git vim nano lvm2 networkmanager dialog efibootmgr ${btrfsPackages}
# generate fstab
genfstab -U /mnt >>/mnt/etc/fstab

curl --output /mnt/root/post-archinstall.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/post-archinstall.sh
curl --output /mnt/root/2-archinstall.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/2-archinstall.sh
sed -i "/set -xe/a hostname='${hostname}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a password='${password}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a diskname='${diskname}'" /mnt/root/2-archinstall.sh
sed -i "/set -xe/a literallyLetterP='${literallyLetterP}'" /mnt/root/2-archinstall.sh
chmod +x /mnt/root/2-archinstall.sh

arch-chroot /mnt /root/2-archinstall.sh

rm /mnt/root/2-archinstall.sh

umount -R /mnt

dialog --title "Congratulations" --yes-label "Reboot" --no-label "Cancel" --yesno "First part of the installation has finished succesfully!\\n\\nDo you want to reboot your computer now?" 0 0
reboot
