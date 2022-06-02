#!/bin/bash

exec 3>&1
username=$(dialog --inputbox "Enter the username:" 0 0 2>&1 1>&3)
exec 3>&-
clear

exec 3>&1
password=$(dialog --inputbox "Enter the password for your user:" 0 0 2>&1 1>&3)
exec 3>&-
clear

cmd=(dialog --separate-output --checklist "Select what you want to install:" 0 0 0)
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
clear

cmdDrivers=(dialog --separate-output --checklist "Select you videocard:" 0 0 0)
optionsDrivers=(
  1 "AMD" on
  2 "Nvidia" off
  3 "Intel" off
  4 "Enable TearFree (for AMD on Xorg)" off
  5 "Enable TearFree (for Intel on Xorg)" off
  6 "Nvidia graphics card on a laptop (envycontrol + nvidia-prime) EXPERIMENTAL" off
)
choicesDrivers=$("${cmdDrivers[@]}" "${optionsDrivers[@]}" 2>&1 >/dev/tty)
clear

cmdDesktop=(dialog --separate-output --title "Select enties with space, confirm with enter" --checklist "Select the desktop environment you want to install:" 0 0 0)
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
clear

cmdApplications=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsApplications=(
  firefox "Standalone web browser from Mozilla" on
  firefox-nightly "Nightly Firefox (AUR)" on
  thunderbird "Standalone mail and news reader from Mozilla" on
  chromium "A web browser from Google" on
  librewolf "Privacy-oriented fork of Firefox (Flatpak)" on
  mpv "A minimalistic media player" on
  yt-dlp "Download videos from YouTube and a few more sites" on
  tauon "Tauon music player (Flatpak)" on
  spotify "A proprietary music streaming service (Flatpak)" off
  keepassxc "Cross-platform port of Keepass password manager" on
  bitwarden "A secure and free password manager (Flatpak)" off
  qbittorrent "An advanced BitTorrent client" on
  fragments "A minimal torrent client for Gnome" off
  code "The Open Source build of Visual Studio Code" on
  code-unlock "Unlock additional features and marketplace (AUR)" on
  code-dotfiles "Install vscode extensions and copy my settings.json" on
  gimp "GNU Image Manipulation Program" on
  kdenlive "A video editor" on
  obs "Software for live streaming and recording" on
  timeshift "A system restore utility (AUR)" on
  timeshift-autosnap "Create a snapshot before system upgrade (use only with BTRFS)" on
  clion "C/C++ IDE (AUR)" off
  discord "All-in-one voice and text chat" off
  discord-flatpak "All-in-one voice and text chat (Flatpak)" off
  telegram "Official Telegram Desktop client (Flatpak)" on
  element "Instant messaging client implementing the Matrix protocol" on
  onlyoffice "An office suite (AUR)" on
  libreoffice "A free and open-source office suite" off
  flacon "An Audio File Encoder (AUR)" off
  helvum "GTK patchbay for PipeWire" on
  easyeffects "An advanced audio manipulation tool, equalizer (Flatpak)" on
  jamesdsp "An audio effect processor, equalizer (AUR)" off
  gitg "Simple Graphical user interface for git" off
)
choicesApplications=$("${cmdApplications[@]}" "${optionsApplications[@]}" 2>&1 >/dev/tty)
clear

cmdGaming=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsGaming=(
  wine "A compatibility layer for running Windows programs" on
  mangohud "An overlay layer for monitoring FPS and more" on
  gamemode "Allows games to request a set of optimisations be temporarily applied to the host OS" on
  steam "Valve's digital software store" on
  proton-ge "ProtonGE (AUR)" off
  steam-flatpak "Valve's digital software store (Flatpak)" off
  goverlay "An application to help manage MangoHud" off
  lutris "Open Gaming Platform" on
  lutris-flatpak "Open Gaming Platform (BETA Flatpak)" off
  gamescope "The micro-compositor" on
)
choicesGaming=$("${cmdGaming[@]}" "${optionsGaming[@]}" 2>&1 >/dev/tty)

cmdFixes=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsFixes=(
  ax210-firmware "AX210 firmware fix" off
  xorg-libinput-accel "Disable Mouse acceleration (Xorg override)" on
  mei_me "Blacklist mei_me kernel module" off
  gnome-monitors "Configure my desktop monitors on gnome" off
)
choicesFixes=$("${cmdFixes[@]}" "${optionsFixes[@]}" 2>&1 >/dev/tty)
clear
