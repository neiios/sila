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

# add hooks
sed -i 's/keyboard/& encrypt lvm2/' /etc/mkinitcpio.conf
mkinitcpio -P

# install and configure systemd-boot
# bootctl install

# cat <<EOF >/boot/loader/loader.conf
# default arch.conf
# timeout 0
# console-mode max
# editor no
# EOF

# cat <<EOF >/boot/loader/entries/arch.conf
# title Arch Linux
# linux /vmlinuz-linux
# initrd /initramfs-linux.img
# options cryptdevice=UUID=$(blkid --match-tag UUID -o value ${diskname}${literallyLetterP}2):luks root=/dev/mapper/vg0-root rw
# EOF

# install grub
pacman -S grub os-prober grub-btrfs --noconfirm --needed
sed -i "s/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=UUID=$(blkid --match-tag UUID -o value ${diskname}${literallyLetterP}2):luks"/" /etc/default/grub
sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
