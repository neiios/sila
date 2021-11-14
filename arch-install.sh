#!/usr/bin/env bash

#Installs grub, networkManager, pipewire, wayland, zram, KDE plasma

# partition the drives (use cfdisk)
#	create boot partition 512M
#		type: efi system partition
#	create root partition (the rest of the space)
#		type: linux filesystem 
#			Good practice: leave around 2G of space at the end
		
# format the drives
#	format boot partition with:
#	mkfs.vfat /dev/sda1
#	format root partition with:
#	mkfs.btrfs /dev/sda2

# mount root partition and create subvolumes:
mount /dev/sdaY /mnt # mount root partition
cd /mnt 
btrfs subvolume create @ # creates root subvolume
#	optional (may be useful for snapshotting):
btrfs subvolume create @home # creates home subvolume
btrfs subvolume create @var # creates var subvolume

# mount subvolumes:
# <----------------STOP HERE AND FIX PARTITION NUMBERS---------------->
umount /mnt
mount -o noatime,compress=zstd,space_cache,discrad=async,subvol=@ /dev/sda2 /mnt 
mkdir /mnt/{boot,home,var}
mount -o noatime,compress=zstd,space_cache,discrad=async,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache,discrad=async,subvol=@var /dev/sda2 /mnt/var

# mount boot partition:
mount /dev/sda1 /mnt/boot

# Select the best mirror
curl -L "https://www.archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&use_mirror_status=on" | sed 's/^#Server/Server/' | head -20 > /etc/pacman.d/mirrorlist.raw
rankmirrors /etc/pacman.d/mirrorlist.raw > /etc/pacman.d/mirrorlist

# Install necessary packages
pacstrap /mnt base linux-zen linux-firmware git vim amd-ucode btrfs-progs man-db man-pages texinfo

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# execute second script and chroot
echo Executing post-init script
curl https://raw.githubusercontent.com/jiulongw/arch-init/master/arch-post.sh > /mnt/root/arch-post.sh //fix this
arch-chroot /mnt "/bin/bash" "/root/arch-post.sh"

umount /mnt
echo All Done. Type "reboot" and go fuck yourself!



