#!/bin/bash

# software input
cmdApplications=(whiptail --separate-output --checklist "Select applications to install:" 0 0 0)
optionsApplications=(
    firefox "Standalone web browser from Mozilla" on
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
)
choicesApplications=$("${cmdApplications[@]}" "${optionsApplications[@]}" 2>&1 >/dev/tty)
clear

for choice in ${choicesApplications}; do
  case ${choice} in
  firefox)
    pacman -S firefox firefox-ublock-origin --noconfirm --needed
    ;;
  chromium)
    pacman -S chromium --noconfirm --needed
    ;;
  librewolf)
    flatpak install -y --noninteractive flathub io.gitlab.librewolf-community
    ;;
  mpv)
    pacman -S mpv --noconfirm --needed
    ;;
  yt-dlp)
    pacman -S yt-dlp atomicparsley ffmpeg python-pycryptodome rtmpdump --noconfirm --needed
    ;;
  tauon)
    flatpak install -y --noninteractive flathub com.github.taiko2k.tauonmb
    ;;
  spotify)
    flatpak install -y --noninteractive flathub com.spotify.Client
    ;;
  keepassxc)
    pacman -S keepassxc xclip wl-clipboard --noconfirm --needed
    ;;
  bitwarden)
    pacman -S bitwarden --noconfirm --needed
    ;;
  thunderbird)
    pacman -S thunderbird libnotify --noconfirm --needed
    ;;
  qbittorrent)
    pacman -S qbittorrent --noconfirm --needed
    ;;
  fragments)
    pacman -S fragments --noconfirm --needed
    ;;
  code)
    pacman -S code --noconfirm --needed
    ;;
  code-unlock)
    sudo -u "${username}" paru -S code-features code-marketplace code-icons --noconfirm --needed
    ;;
  gimp)
    pacman -S gimp poppler-glib --noconfirm --needed
    ;;
  kdenlive)
    pacman -S kdenlive opencv opentimelineio --noconfirm --needed
    ;;
  obs)
    pacman -S obs-studio libfdk-aac v4l2loopback-dkms --noconfirm --needed
    ;;
  timeshift)
    sudo -u "${username}" paru -S timeshift --noconfirm --needed
    ;;
  timeshift-autosnap)
    sudo -u "${username}" paru -S timeshift-autosnap --noconfirm --needed
    ;;
  clion)
    sudo -u "${username}" paru -S clion clion-cmake clion-gdb clion-lldb clion-jre --noconfirm --needed
    ;;
  discord)
    pacman -S discord --noconfirm --needed
    ;;
  discord-flatpak)
    flatpak install -y --noninteractive flathub com.discordapp.Discord
    ;;
  telegram)
    flatpak install -y --noninteractive flathub org.telegram.desktop
    ;;
  element)
    pacman -S element-desktop --noconfirm --needed
    ;;
  onlyoffice)
    sudo -u "${username}" paru -S onlyoffice-bin --noconfirm --needed
    ;;
  libreoffice)
    pacman -S libreoffice-fresh --noconfirm --needed
    ;;
  flacon)
    sudo -u "${username}" paru -S flacon flac lame mac opus-tools sox vorbis-tools vorbisgain wavpack --noconfirm --needed
    ;;
  helvum)
    pacman -S helvum --noconfirm --needed
    ;;
  easyeffects)
    flatpak install -y --noninteractive flathub com.github.wwmm.easyeffects
    ;;
  jamesdsp)
    sudo -u "${username}" paru -S jamesdsp --noconfirm --needed
    ;;
  esac
done
