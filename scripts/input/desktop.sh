#!/bin/bash

cmd=(whiptail --separate-output --checklist "Select basic packages to install (you most likely want all of them):" 0 0 0)
optionsGeneral=(
  devel "A lot of development tools" on
  pipewire "Audio/video server" on
  bluetooth "Bluetooth" on
  gstreamer "Install additional codecs" on
  flatpak "Flatpak support (will break the script if deselected)" on
  vm "VMs (Qemu+KVM)" on
  cups "Printing support (CUPS)" on
  zsh "Zsh" on
  zram "ZRAM" on
)
choicesGeneral=$("${cmd[@]}" "${optionsGeneral[@]}" 2>&1 >/dev/tty)

cmdDesktop=(whiptail --separate-output --checklist "Select the desktop environment you want to install:" 0 0 0)
optionsDesktop=(
  gnome "GNOME" on
  gnome-additional-apps "Some additional apps (can be installed later)" off
  adw-gtk3 "Install adw-gtk3 theme for gnome" off
  kde "KDE Plasma" off
  dotfiles "Copy my dotfiles" on
  ppd "Power profiles daemon" on
  tlp "TLP" off
)
choicesDesktop=$("${cmdDesktop[@]}" "${optionsDesktop[@]}" 2>&1 >/dev/tty)
