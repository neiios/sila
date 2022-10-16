#!/bin/bash
set -e

# functions
function enterHostname() {
  while true; do
    h=$(whiptail --title "Hostname" --nocancel --inputbox "${invalidMessage}Enter the hostname for this computer:" 0 0 3>&1 1>&2 2>&3)
    [[ "${h}" =~ ^[a-zA-Z0-9]+(([a-zA-Z0-9-])*[a-zA-Z0-9]+)*$ ]] && echo "${h}" && break
    invalidMessage="The hostname is invalid.\nA valid hostname contains only letters from a to Z, numbers, and the hyphen (-).\nA hostname may not start or end with a hyphen.\n"
  done
}

# dont run this script without setting needed env vars
# shellcheck source=/scripts/vars.sh
source /root/alis/scripts/vars.sh

# enter hostname
hostname="$(enterHostname)"

# set hostname
echo "$hostname" >/etc/hostname
cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${hostname}
EOF

# set timezone
ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
hwclock --systohc

sed -i "s/#C.UTF-8 UTF-8/C.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#en_IE.UTF-8 UTF-8/en_IE.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#lt_LT.UTF-8 UTF-8/lt_LT.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/" /etc/locale.gen
sed -i "s/#nl_NL.UTF-8 UTF-8/nl_NL.UTF-8 UTF-8/" /etc/locale.gen
locale-gen

# create locale.conf
cat <<EOF >/etc/locale.conf
# use us locale because some software may freak out when locale is set to something else
LANG="en_US.UTF-8"
# sort dotfiles, then uppercase, then lowercase
LC_COLLATE="C.UTF-8"
# better date and time
LC_TIME="en_IE.UTF-8"
# metric system
LC_MEASUREMENT="lt_LT.UTF-8"
LC_PAPER="lt_LT.UTF-8"
# euro
LC_MONETARY="lt_LT.UTF-8"
# system message language
LC_MESSAGES="en_US.UTF-8"
EOF

# configure root password
echo "root:$password" | chpasswd

# network
pacman -S networkmanager --noconfirm --needed
systemctl enable NetworkManager

# bootloader
pacman -S grub os-prober grub-btrfs --noconfirm --needed

# change these options only if the drive should be encrypted
if [[ -n $passwordLuks ]]; then
  sed -i "s/block/& encrypt/" /etc/mkinitcpio.conf
  mkinitcpio -P
  sed -i '/GRUB_CMDLINE_LINUX=""/d' /etc/default/grub
  grubCmdline="cryptdevice=UUID=$(blkid --match-tag UUID -o value "$rootPartition"):luks root=/dev/mapper/luks rootflags=subvol=@"
  echo GRUB_CMDLINE_LINUX="$grubCmdline" >>/etc/default/grub
fi

sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/" /etc/default/grub

# script can be used for both uefi and bios machines
if [[ $UEFIBIOS -eq 1 ]]; then
    pacman -S efibootmgr --noconfirm --needed
    grub-install --target=x86_64-efi "$diskname" --efi-directory=/boot --recheck
else
    grub-install "$diskname"
fi

grub-mkconfig -o /boot/grub/grub.cfg

bash /root/alis/scripts/postinstall.sh
