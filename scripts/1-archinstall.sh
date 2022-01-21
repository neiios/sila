#!/usr/bin/env bash

set -xe
timedatectl set-ntp true

lsblk -f
read -r -p "Enter disk to format (/dev/sda, /dev/vda, /dev/nvme0n1):" diskname
echo "You selected: " $diskname

# ----------------------------- create partitions -----------------------------
# this is a point of no return
sgdisk --zap-all --clear ${diskname}

sgdisk -n 0:0:+1GiB -t 0:ea00 -c 0:boot $diskname
sgdisk -n 0:0:0 -t 0:8300 -c 0:root $diskname
sgdisk -p $diskname
# ----------------------------- create partitions -----------------------------

# ----------------------------- btrfs section -----------------------------
# NOTE: genfstab creates both subvolid and subvol (this fucks up timeshift)
# NOTE: space_cache doesn't work not sure what the reason is (space_cache=v2 does work)

# mkfs.vfat ${diskname}1
# mkfs.btrfs ${diskname}2 -L root -f

# mount ${diskname}2 /mnt # mount root partition
# cd /mnt
# btrfs subvolume create @
# btrfs subvolume create @home
# btrfs subvolume create @var
# echo "Subvolumes created"

# umount -R /mnt
# mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ ${diskname}2 /mnt
# mkdir /mnt/{boot,home,var}
# mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@home ${diskname}2 /mnt/home
# mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@var ${diskname}2 /mnt/var
# ----------------------------- btrfs section -----------------------------

# ----------------------------- ext4 section -----------------------------
mkfs.vfat ${diskname}1
mkfs.ext4 ${diskname}2

mkdir -p /mnt/boot
mount ${diskname}2 /mnt
mount ${diskname}1 /mnt/boot
# ----------------------------- ext4 section -----------------------------

lsblk -f
echo "Drive formatted and partitions mounted"

# Install necessary packages
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware git pacman-contrib vim man-db man-pages texinfo

# Generate fstab file
genfstab -U /mnt >>/mnt/etc/fstab

# ----------------------------- second script -----------------------------
echo "Executing second script"
cp /root/script/scripts/2-archinstall.sh /mnt/root/2-archinstall.sh
arch-chroot /mnt /root/2-archinstall.sh
# ----------------------------- second script -----------------------------

rm /mnt/root/2-archinstall.sh
umount -R /mnt

echo "All Done"
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
