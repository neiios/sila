#!/bin/bash

# destroying the drive (i am trying really hard)
wipefs -af ${diskname}
mkfs.ext4 ${diskname}
dd if=/dev/zero of=${diskname} bs=1M count=32

UEFIBIOS=1
ls /sys/firmware/efi &>/dev/null || UEFIBIOS=0

if [ ${UEFIBIOS} == 1 ]; then
    # UEFI
    sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:efi ${diskname}
    sgdisk -n 0:0:0 -t 0:8300 -c 0:luks ${diskname}
    sgdisk -p ${diskname}
else
    # BIOS
    echo -e 'size=512M\n size=+\n' | sfdisk --label dos ${diskname}
fi

bootPartition=${diskname}${literallyLetterP}1
rootPartition=${diskname}${literallyLetterP}2

# format boot
mkfs.vfat ${bootPartition}

# encrypt root volume if password is given
if [[ -n ${passwordLuks} ]]; then 
  echo "${passwordLuks}" | cryptsetup -q luksFormat $rootPartition
  echo "${passwordLuks}" | cryptsetup open $rootPartition luks
  mappedRoot=/dev/mapper/luks
else
  mappedRoot=$rootPartition
fi

# format root partition
mkfs.btrfs ${mappedRoot} -f

# create subvolumes
mount ${mappedRoot} /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@log
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@snapshots
umount -R /mnt

# mount subvolumes
mount -o noatime,compress=zstd,subvol=@ ${mappedRoot} /mnt
mkdir -pv /mnt/{boot,home,var/log,var/cache/pacman/pkg,.snapshots}
mount -o noatime,compress=zstd,subvol=@home ${mappedRoot} /mnt/home
mount -o noatime,compress=zstd,subvol=@log ${mappedRoot} /mnt/var/log
mount -o noatime,compress=zstd,subvol=@pkg ${mappedRoot} /mnt/var/cache/pacman/pkg
mount -o noatime,compress=zstd,subvol=@snapshots ${mappedRoot} /mnt/.snapshots

# mount boot
mount ${bootPartition} /mnt/boot

