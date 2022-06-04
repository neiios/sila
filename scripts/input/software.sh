#!/bin/bash

cmdApplications=(dialog --separate-output --title "Select entries with space, confirm with enter" --checklist "Select applications to install:" 0 0 0)
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
