#!/bin/bash

function usernameInput() {
    while true; do
        u=$(whiptail --title "Username" --inputbox "${invalidMessage}Enter the username:" 0 0 3>&1 1>&2 2>&3)
        [[ "${u}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]] && echo "${u}" && break
        invalidMessage="The username is invalid.\nValid username should contain up to 32 lowercase letters, number, underscores and hyphens.\nThe username may end with a \$.\n"
    done
}

username=$(usernameInput)

function inputPass() {
    while true; do
        t=$(whiptail --title "$1 password" --passwordbox "${invalidPasswordMessage}Enter the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        t2=$(whiptail --title "$1 password" --passwordbox "Retype the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        [[ "${t}" == "${t2}" ]] && [[ -n "${t}" ]] && [[ -n "${t2}" ]] && echo "${t}" && break
        # special case for disk encryption (it can be an empty string)
        [[ "${t}" == "${t2}" ]] && [[ "$1" == "Disk encryption" ]] && echo "${t}" && break
        invalidPasswordMessage="The passwords did not match or you have entered an empty string.\n\n"
    done
}

password="$(inputPass "Regular user")"

# drivers input
cmdDrivers=(whiptail --separate-output --checklist "Select the drivers you want to use:" 0 0 0)
optionsDrivers=(
    amd "AMD" on
    nvidia-proprietary "Nvidia (proprietary)" off
    intel-new "Intel (from Broadwell)" off
    intel-old "Intel (older CPUs)" off
)
choicesDrivers=$("${cmdDrivers[@]}" "${optionsDrivers[@]}" 2>&1 >/dev/tty)

# desktop input
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

# gaming input
cmdGaming=(whiptail --separate-output --checklist "Select applications to install:" 0 0 0)
optionsGaming=(
    wine "A compatibility layer for running Windows programs" on
    mangohud "An overlay layer for monitoring FPS and more" off
    gamemode "Allows games to request a set of optimisations be temporarily applied to the host OS" off
    steam "Valve's digital software store" off
    steam-flatpak "Valve's digital software store (Flatpak)" off
    proton-ge "ProtonGE (AUR)" off
    gamescope "The micro-compositor" off
    goverlay "An application to help manage MangoHud" off
    lutris "Open Gaming Platform" off
    lutris-flatpak "Open Gaming Platform (Flatpak)" off
)
choicesGaming=$("${cmdGaming[@]}" "${optionsGaming[@]}" 2>&1 >/dev/tty)

# fixes input
cmdFixes=(whiptail --separate-output --checklist "Select some fixes/workarounds you want to apply:" 0 0 0)
optionsFixes=(
    ax210-firmware "AX210 firmware fix" off
    xorg-libinput-accel "Disable Mouse acceleration (Xorg override)" off
    mei_me "Blacklist mei_me kernel module" off
    gnome-monitors "Configure my desktop monitors on gnome" off
    tearfree-amd "Xorg TearFree AMD" off
    tearfree-intel "Xorg TearFree Intel" off
    sddm-wayland "Run sddm on wayland" off
    elan-trackpad "Fixes broken Elan trackpad on Lenovo Yoga Slim 7" off
    ms-fonts "Some microsoft fonts (the least broken package) (AUR)" off
)
choicesFixes=$("${cmdFixes[@]}" "${optionsFixes[@]}" 2>&1 >/dev/tty)
