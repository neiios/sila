#!/bin/bash

function error() {
  echo "${1:-"Unknown Error"}" 1>&2
  exit 1
}

function setHostname() {
  # get hostname from the user
  while true; do
    hostname=$(whiptail --nocancel --inputbox --title "Hostname" "${invalidMessage}Enter the hostname for this computer:" 0 0 3>&1 1>&2 2>&3)
    [[ "${hostname}" =~ ^[a-zA-Z0-9]+(([a-zA-Z0-9-])*[a-zA-Z0-9]+)*$ ]] && break
    invalidMessage="The hostname is invalid.\nA valid hostname contains only letters from a to Z, numbers, and the hyphen (-).\nA hostname may not start or end with a hyphen.\n"
  done
  clear

  # set hostname
  echo "$hostname" >/etc/hostname
  cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${hostname}
EOF
}

function setTimezone() {
  # TODO: unhardcode it
  ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
  hwclock --systohc
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
  localectl set-keymap --no-convert us
}

function configureRootUser() {
  # get root password
  while true; do
    rootPassword=$(whiptail --nocancel --passwordbox --title "Root password" "${invalidPasswordMessage}Enter the root password:" 10 50 3>&1 1>&2 2>&3)
    rootPassword2=$(whiptail --nocancel --passwordbox --title "Confirm root password" "Retype the root password:" 10 50 3>&1 1>&2 2>&3)
    [[ "${rootPassword}" == "${rootPassword2}" && -n "${rootPassword}" && -n "${rootPassword2}" ]] && break
    invalidPasswordMessage="The passwords did not match or you have entered an empty password.\n\n"
  done
  clear

  # configure root password
  echo "root:$rootPassword" | chpasswd
  echo 'alias vim=nvim' >>/etc/bashrc
}

function configureNetwork() {
  pacman -S networkmanager --noconfirm --needed
  systemctl enable NetworkManager
}

function installGrub() {
  pacman -S grub efibootmgr os-prober --noconfirm --needed

  # change udev to systemd
  sed -i "/^HOOKS/ s/udev/systemd/" /etc/mkinitcpio.conf
  # remove keyboard
  sed -i "/^HOOKS/ s/keyboard //" /etc/mkinitcpio.conf
  # add keyboard after autodetect
  sed -i "/^HOOKS/ s/autodetect/& keyboard/" /etc/mkinitcpio.conf
  # add sd-vconsole after keyboard
  sed -i "/^HOOKS/ s/keyboard/& sd-vconsole/" /etc/mkinitcpio.conf

  # change these options only if the drive should be encrypted
  if [[ $ENCRYPTION -eq 1 ]]; then
    # add sd-encrypt after block
    sed -i "/^HOOKS/ s/block/& sd-encrypt/" /etc/mkinitcpio.conf
    sed -i '/GRUB_CMDLINE_LINUX=""/d' /etc/default/grub
    grubCmdline="rd.luks.name=$(blkid --match-tag UUID -o value "$rootPartition")=luks root=$mappedRoot rootflags=subvol=@"
    echo GRUB_CMDLINE_LINUX="$grubCmdline" >>/etc/default/grub
  fi

  mkinitcpio -P

  # edit config
  sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
  sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/" /etc/default/grub

  # script can be used for both uefi and bios machines
  if [[ $UEFI -eq 1 ]]; then
    grub-install --target=x86_64-efi --bootloader-id=ARCH --efi-directory=/boot --recheck
  else
    grub-install --target=i386-pc "$selectedDisk"
  fi

  # create config
  grub-mkconfig -o /boot/grub/grub.cfg
}

# main
# dont run this script by itself without setting needed env vars
# shellcheck source=/scripts/vars.sh
source /root/alis/scripts/vars.sh

setHostname || error "Failed to set a hostname."

setTimezone || error "Failed to set a timezone."

createLocales || error "Failed to create locales."

configureRootUser || error "Failed to configure the root user."

configureNetwork || error "Failed to configure a network."

installGrub || error "Failed to install grub bootloader."

# fuck the beeper
rmmod pcspkr
echo "blacklist pcspkr" >/etc/modprobe.d/nobeep.conf

# run postinstall script after reboot
echo "bash /root/alis/scripts/postinstall.sh" >>/root/.profile
