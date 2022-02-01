#!/usr/bin/env bash
set -xe

echo $hostname >/etc/hostname
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

# configure users
echo root:${password} | chpasswd

# network
pacman -S networkmanager wpa_supplicant --noconfirm --needed
systemctl enable NetworkManager.service

pacman -S grub efibootmgr os-prober grub-btrfs btrfs-progs --noconfirm --needed
# install grub and generate a config
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >>/etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# ----------------------------- unused -----------------------------

# Hiding desktop entries (doesnt work on kde)
# echo "[Desktop Entry]
# Hidden=true" >/tmp/1
# mkdir -pv ~/.local/share/applications/
# find /usr -name "*lsp_plug*desktop" 2>/dev/null | cut -f 5 -d '/' | xargs -I {} cp -f /tmp/1 ~/.local/share/applications/{}

# mkdir -pv ~/.config/easyeffects/output/
# cp ~/ALIS/configs/Audeze\ iSine\ 20\ Harman\ Oratory.json ~/.config/easyeffects/output/Audeze\ iSine\ 20\ Harman\ Oratory.json
