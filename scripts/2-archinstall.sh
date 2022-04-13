#!/usr/bin/env bash
set -xe

# dont run this script without setting needed env vars

echo ${hostname} >/etc/hostname
cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${hostname}.localdomain ${hostname}
EOF

ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
hwclock --systohc

sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#en_IE.UTF-8 UTF-8/en_IE.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#lt_LT.UTF-8 UTF-8/lt_LT.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
echo "LANG=en_IE.UTF-8" >/etc/locale.conf

# configure root password
echo root:${password} | chpasswd

# network
pacman -S networkmanager --noconfirm --needed
systemctl enable NetworkManager

# generate a key to not enter password twice
dd bs=512 count=4 if=/dev/urandom of=/crypto_keyfile.bin
echo "${passwordLuks}" | cryptsetup luksAddKey ${rootPartition} /crypto_keyfile.bin
chmod 000 /crypto_keyfile.bin

# bootloader (GRUB)
sed -i "s/block/& encrypt/" /etc/mkinitcpio.conf
sed -i "s|FILES=()|FILES=(/crypto_keyfile.bin)|" /etc/mkinitcpio.conf
mkinitcpio -P

pacman -S grub os-prober grub-btrfs --noconfirm --needed
sed -i '/GRUB_CMDLINE_LINUX=""/d' /etc/default/grub
echo GRUB_CMDLINE_LINUX="cryptdevice=UUID=$(blkid --match-tag UUID -o value ${rootPartition}):luks root=/dev/mapper/luks rootflags=subvol=@" >>/etc/default/grub
sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
if [ ${UEFIBIOS} == 1 ]; then
    pacman -S efibootmgr --noconfirm --needed
    grub-install --target=x86_64-efi ${diskname} --efi-directory=/efi --recheck
else
    grub-install ${diskname}
fi

grub-mkconfig -o /boot/grub/grub.cfg
