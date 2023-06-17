#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function setHostname() {
  # get hostname from the user
  invalidMessage=""
  while true; do
    hostname=$(dialog --erase-on-exit --nocancel --title "Hostname" \
      --inputbox "${invalidMessage}Enter the hostname for this computer:" 0 0 3>&1 1>&2 2>&3)
    [[ "${hostname}" =~ ^[a-zA-Z0-9]+(([a-zA-Z0-9-])*[a-zA-Z0-9]+)*$ ]] && break
    invalidMessage="The hostname is invalid.\nA valid hostname contains only letters from a to Z, numbers, and the hyphen (-).\nA hostname may not start or end with a hyphen.\n"
  done

  # set hostname
  echo "$hostname" >/etc/hostname
  cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${hostname}
EOF
}

function createLocales() {
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

  # set keymap
  echo "KEYMAP=us" >>/etc/vconsole.conf
}

function configureRootUser() {
  # get root password
  invalidPasswordMessage=""
  while true; do
    rootPassword=$(dialog --erase-on-exit --nocancel --title "Root password" \
      --insecure --passwordbox "${invalidPasswordMessage}Enter the root password:" 0 0 3>&1 1>&2 2>&3)
    rootPassword2=$(dialog --erase-on-exit --nocancel --title "Confirm root password" \
      --insecure --passwordbox "Retype the root password:" 0 0 3>&1 1>&2 2>&3)
    [[ "${rootPassword}" == "${rootPassword2}" && -n "${rootPassword}" ]] && break
    invalidPasswordMessage="The passwords did not match or you have entered an empty password.\n\n"
  done

  # configure root password
  echo "root:$rootPassword" | chpasswd
  unset rootPassword rootPassword2
}

function configureNetwork() {
  pacman -S networkmanager --noconfirm --needed
  systemctl enable NetworkManager
}

function installSystemdBoot() {
  bootctl install

  cat <<EOF >/boot/loader/loader.conf
default       arch.conf
timeout       0
console-mode  max
editor        no
EOF

  cat <<EOF >/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /initramfs-linux.img
EOF

  if [[ $ENCRYPTION -eq 1 ]]; then
    echo "options rd.luks.name=$(blkid --match-tag UUID -o value "$rootPartition")=luks root=$mappedRoot rootflags=subvol=@ quiet splash" >>/boot/loader/entries/arch.conf
  else
    echo "options root=UUID=\"$(blkid --match-tag UUID -o value "$rootPartition")\" rootflags=subvol=@ quiet splash rw" >>/boot/loader/entries/arch.conf
  fi
}

function installGrub() {
  pacman -S grub os-prober --noconfirm --needed

  # change these options only if the drive should be encrypted
  if [[ $ENCRYPTION -eq 1 ]]; then
    # add sd-encrypt after block
    sed -i "/^HOOKS/ s/block/& sd-encrypt/" /etc/mkinitcpio.conf
    sed -i '/GRUB_CMDLINE_LINUX=""/d' /etc/default/grub
    grubCmdline="rd.luks.name=$(blkid --match-tag UUID -o value "$rootPartition")=luks root=$mappedRoot rootflags=subvol=@"
    echo GRUB_CMDLINE_LINUX="$grubCmdline" >>/etc/default/grub
  fi

  sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
  sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/" /etc/default/grub

  grub-install --target=i386-pc "$selectedDisk"

  grub-mkconfig -o /boot/grub/grub.cfg
}

function installBootloader() {
  pacman -S plymouth edk2-shell efibootmgr efibootmgr dosfstools --noconfirm --needed

  # change udev to systemd
  sed -i "/^HOOKS/ s/udev/systemd/" /etc/mkinitcpio.conf
  # remove keyboard
  sed -i "/^HOOKS/ s/keyboard //" /etc/mkinitcpio.conf
  # add keyboard after autodetect
  sed -i "/^HOOKS/ s/autodetect/& keyboard/" /etc/mkinitcpio.conf
  # add sd-vconsole after keyboard
  sed -i "/^HOOKS/ s/keyboard/& sd-vconsole/" /etc/mkinitcpio.conf
  sed -i "/^HOOKS/ s/fsck/& plymouth/" /etc/mkinitcpio.conf

  mkinitcpio -P

  if [[ "$UEFI" == "1" ]]; then
    installSystemdBoot
  else
    installGrub
  fi
}

# dont run this script by itself without setting needed env vars
# shellcheck source=/scripts/vars.sh
source /root/sila/scripts/vars.sh

setHostname
createLocales
configureRootUser
configureNetwork
installBootloader

# fuck the beeper
rmmod pcspkr
echo "blacklist pcspkr" >/etc/modprobe.d/nobeep.conf

# run postinstall script after reboot
echo "bash /root/sila/scripts/postinstall.sh" >>/root/.profile
