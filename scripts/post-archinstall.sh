#!/usr/bin/env bash
set -xe

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# ----------------------------- inputs -----------------------------
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
    1 "Sound server (pipewire)" on
    2 "Bluetooth" on
    3 "Set up software needed for VMs" on
    4 "Enable firewall (ufw)" on
    6 "Printing support (CUPS)" on
    7 "HP printer support" off
    8 "Flatpak support" on
    9 "Install and configure zsh" on
    10 "Configure ZRAM" on
    11 "Additional fonts" on
    12 "Install additional codecs" on
)
choicesGeneral=$("${cmd[@]}" "${optionsGeneral[@]}" 2>&1 >/dev/tty)
clear

cmdDrivers=(dialog --separate-output --checklist "Select you videocard:" 16 64 4)
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

cmdDesktop=(dialog --separate-output --title "Select enties with space, confirm with enter" --checklist "Select the desktop environment you want to install:" 16 64 4)
optionsDesktop=(
    1 "KDE Plasma" on
    2 "GNOME" off
    3 "Configure GNOME settings (my config)" off
    4 "Configure my monitors on Gnome" off
    5 "Copy the dotfiles" on
    6 "Disable Mouse acceleration (for login managers)" on
    7 "Power profiles daemon" on
    8 "TLP" off
    9 "tlp-rdw" off
    10 "AX210 fix" off
    11 "Blacklist mei_me kernel module" off
)
choicesDesktop=$("${cmdDesktop[@]}" "${optionsDesktop[@]}" 2>&1 >/dev/tty)
clear

cmdApplications=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsApplications=(
    devel "Basic packages for development (gcc, clang, llvm, cmake...)" on
    flatseal "Manage Flatpak permissions (Flatpak)" on
    chromium "A web browser from Google" on
    librewolf "Privacy-oriented fork of Firefox (Flatpak)" on
    firefox "Standalone web browser from Mozilla" on
    mpv "A minimalistic media player" on
    yt-dlp "Download videos from YouTube and a few more sites" on
    spotify "A proprietary music streaming service (Flatpak)" off
    keepassxc "Cross-platform port of Keepass password manager" on
    bitwarden "A secure and free password manager (Flatpak)" off
    thunderbird "Standalone mail and news reader from Mozilla" on
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
    clion "C/C++ IDE" off
    discord "All-in-one voice and text chat" off
    discord-flatpak "All-in-one voice and text chat (Flatpak)" on
    telegram "Official Telegram Desktop client" on
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
    steam-flatpak "Valve's digital software store (Flatpak)" off
    goverlay "An application to help manage MangoHud" off
    lutris "Open Gaming Platform" on
    lutris-flatpak "Open Gaming Platform (BETA Flatpak)" off
    gamescope "The micro-compositor" on
)
choicesGaming=$("${cmdGaming[@]}" "${optionsGaming[@]}" 2>&1 >/dev/tty)
clear
# ----------------------------- inputs -----------------------------

pacman -Syy archlinux-keyring --noconfirm
pacman -S dialog git base-devel --noconfirm --needed

useradd -m ${username}
usermod -aG wheel ${username}
echo ${username}:${password} | chpasswd
# edit /etc/sudoers (there is 2 different variants)
sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

# configure pacman
sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -i "s/^#VerbosePkgLists/VerbosePkgLists/" /etc/pacman.conf
sed -i "s/^#Color/Color/" /etc/pacman.conf
sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 5/" /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Syy

# configure make
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# install paru-bin
git clone https://aur.archlinux.org/paru-bin.git /home/${username}/paru-bin
cd /home/${username}/paru-bin
chown ${username}:${username} /home/${username}/paru-bin
sudo -u ${username} makepkg -si --noconfirm --needed
rm -rf /home/${username}/paru-bin
# currently paru has a nasty bug
# see: https://github.com/Morganamilo/paru/issues/631#issuecomment-998703406
# paru needs to be called from a directory owned by the current user
chown -R ${username}:${username} /home/${username}
cd /home/${username}

# basic utilities
pacman -S xorg pacman-contrib reflector man-db man-pages texinfo curl wget cronie openssh sshfs rsync efibootmgr dosfstools mtools nfs-utils inetutils libusb usbutils usbguard libusb-compat avahi nss-mdns xdg-utils xdg-user-dirs acpi acpi_call bash-completion sof-firmware elfutils patch ffmpeg libdecor net-tools openssh wget htop --noconfirm --needed

systemctl enable avahi-daemon.service
sed -i "s/mymachines /&mdns_minimal [NOTFOUND=return] /" /etc/nsswitch.conf
systemctl enable cronie.service
systemctl enable reflector.timer
systemctl enable paccache.timer
# dont enable on an encrypted drive
# systemctl enable fstrim.timer
# TODO: remove ntfs-3g
pacman -S ntfs-3g --noconfirm --needed

# check hypervisor
if [ $(dmesg | grep "Hypervisor detected" | wc -l) -ne 0 ]; then
    echo "Virtual machine detected. Installing additional tools."
    pacman -S qemu-guest-agent spice-vdagent virtualbox-guest-utils --noconfirm --needed
    systemctl enable qemu-guest-agent.service
fi

for choice in ${choicesGeneral}; do
    case ${choice} in
    1)
        yes y | pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pipewire-v4l2 pipewire-zeroconf gst-plugin-pipewire helvum
        # multilib
        yes y | pacman -S lib32-pipewire lib32-pipewire-jack lib32-pipewire-v4l2
        ;;
    2)
        pacman -S bluez bluez-utils --noconfirm --needed
        systemctl enable bluetooth.service
        ;;
    3)
        yes y | pacman -S libvirt qemu qemu-arch-extra edk2-ovmf iptables-nft dnsmasq dmidecode bridge-utils openbsd-netcat virt-manager
        systemctl enable libvirtd.service
        usermod -aG libvirt $username
        ;;
    4)
        pacman -S ufw ufw-extras --noconfirm --needed
        systemctl enable ufw.service
        ufw default allow outgoing
        ufw default deny incoming
        ufw allow Bonjour
        ufw allow "KDE Connect"
        ufw enable
        ;;
    6)
        pacman -S cups cups-pk-helper cups-filters cups-pdf ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds system-config-printer --noconfirm --needed
        systemctl enable cups.socket
        ;;
    7)
        # not tested (and probably never will be)
        pacman -S hplip python-pillow python-pyqt5 python-reportlab python-reportlab sane --noconfirm --needed
        ;;
    8)
        # need to explicitly install gtk portal, because flatpak pulls gnome portal and its dependencies without it
        pacman -S flatpak flatpak-xdg-utils flatpak-builder xdg-desktop-portal-gtk elfutils patch --noconfirm --needed
        ;;
    9)
        mkdir -pv /${username}/.cache/zsh/
        pacman -S zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting --noconfirm --needed
        curl --output /home/${username}/.zshrc https://raw.githubusercontent.com/richard96292/ALIS/master/configs/.zshrc
        chsh -s $(which zsh) ${username}
        ;;
    10)
        pacman -S zram-generator --noconfirm --needed
        echo "[zram0]" >/etc/systemd/zram-generator.conf
        echo "zram-size = min(ram / 2, 4096)" >>/etc/systemd/zram-generator.conf
        systemctl daemon-reload
        systemctl start /dev/zram0
        zramctl
        ;;
    11)
        # bitmap
        pacman -S dina-font tamsyn-font terminus-font --noconfirm --needed
        # latin script
        pacman -S ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation libertinus-font noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-caladea ttf-carlito --noconfirm --needed
        # monospaced
        pacman -S ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-fira-code ttf-inconsolata ttc-iosevka ttf-jetbrains-mono adobe-source-code-pro-fonts --noconfirm --needed
        # sans-serif
        pacman -S cantarell-fonts ttf-fira-sans inter-font ttf-opensans adobe-source-sans-fonts --noconfirm --needed
        # serif
        pacman -S gentium-plus-font libertinus-font adobe-source-serif-fonts --noconfirm --needed
        # unsorted
        pacman -S ttf-junicode --noconfirm --needed
        # asian
        pacman -S adobe-source-han-sans-otc-fonts adobe-source-han-sans-cn-fonts adobe-source-han-sans-tw-fonts adobe-source-han-serif-otc-fonts adobe-source-han-serif-cn-fonts adobe-source-han-serif-tw-fonts wqy-microhei wqy-zenhei wqy-bitmapfont ttf-arphic-ukai ttf-arphic-uming opendesktop-fonts ttf-hannom adobe-source-han-sans-jp-fonts adobe-source-han-serif-jp-fonts otf-ipafont ttf-hanazono ttf-sazanami adobe-source-han-sans-kr-fonts adobe-source-han-serif-kr-fonts ttf-baekmuk ttf-indic-otf ttf-khmer ttf-tibetan-machine noto-fonts-cjk --noconfirm --needed
        # emoji and symbols
        pacman -S ttf-font-awesome noto-fonts-emoji ttf-joypixels --noconfirm --needed
        # math
        pacman -S otf-latin-modern otf-latinmodern-math --noconfirm --needed
        ;;
    12)
        # gstreamer (pulls all releveant codecs)
        pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-bad-libs gst-plugins-ugly --noconfirm --needed
        ;;
    esac
done

for choice in ${choicesDrivers}; do
    case ${choice} in
    1)
        # amd drivers
        pacman -S mesa mesa-utils vulkan-radeon vulkan-mesa-layers libva-mesa-driver mesa-vdpau vulkan-icd-loader --noconfirm --needed
        # multilib
        pacman -S lib32-mesa lib32-mesa-utils lib32-vulkan-radeon lib32-vulkan-mesa-layers lib32-libva-mesa-driver lib32-mesa-vdpau lib32-vulkan-icd-loader --noconfirm --needed
        # xorg amd driver
        pacman -S xf86-video-amdgpu --noconfirm --needed
        # additional
        pacman -S radeontop --noconfirm --needed
        ;;
    2)
        # i think explicitly installing mesa is still generally a good idea
        pacman -S mesa mesa-utils lib32-mesa lib32-mesa-utils --noconfirm --needed
        # nvidia drivers
        pacman -S nvidia nvidia-utils vulkan-icd-loader opencl-nvidia --noconfirm --needed
        # multilib
        pacman -S lib32-nvidia-utils lib32-opencl-nvidia lib32-vulkan-icd-loader --noconfirm --needed
        # additional
        pacman -S nvidia-settings nvtop --noconfirm --needed
        ;;
    3)
        # intel drivers
        pacman -S mesa mesa-utils vulkan-intel vulkan-icd-loader vulkan-mesa-layers intel-media-driver libva-intel-driver --noconfirm --needed
        # xorg driver
        pacman -S xf86-video-intel --noconfirm --needed
        # multilib
        pacman -S lib32-mesa lib32-vulkan-intel lib32-vulkan-icd-loader lib32-vulkan-mesa-layers --noconfirm --needed
        ;;
    4)
        cat <<EOF >/etc/X11/xorg.conf.d/20-amdgpu.conf
Section "Device"
	Identifier "AMD GPU"
	Driver "amdgpu"
	Option "TearFree" "true"
EndSection
EOF
        ;;
    5)
        cat <<EOF >/etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
	Identifier "Intel GPU"
	Driver "intel"
	Option "TearFree" "true"
EndSection
EOF
        ;;
    6)
        pacman -S nvidia-prime --noconfirm --needed
        paru -S envycontrol --noconfirm --needed
        ;;
    esac
done

for choice in ${choicesDesktop}; do
    case ${choice} in
    1)
        # install basic plasma group
        # https://archlinux.org/groups/x86_64/plasma/
        pacman -S plasma plasma-wayland-session sddm --noconfirm --needed
        # phonon backend
        pacman -S phonon-qt5-gstreamer --noconfirm --needed
        # plasma applications
        pacman -S konsole dolphin elisa vlc gwenview kamoso spectacle okular kolourpaint skanlite kdeconnect kwrite kdenlive kcalc ksystemlog partitionmanager kfind kwalletmanager filelight ark print-manager --noconfirm --needed
        # for kdeconnect
        pacman -S sshfs --noconfirm --needed
        # for kio-extras
        pacman -S kio-gdrive icoutils kimageformats karchive libavif libheif libjxl openexr libappimage qt5-imageformats taglib --noconfirm --needed
        # for dolphin
        pacman -S ffmpegthumbs kdegraphics-thumbnailers kdenetwork-filesharing audiocd-kio zeroconf-ioslave --noconfirm --needed
        # for discover
        pacman -S fwupd packagekit-qt5 --noconfirm --needed
        # for ark
        pacman -S lrzip lzop p7zip unarchiver svgpart --noconfirm --needed
        # for okular
        pacman -S ebook-tools kdegraphics-mobipocket --noconfirm --needed
        # for kdenlive
        pacman -S opencv opentimelineio --noconfirm --needed
        # for kdeplasma-addons
        pacman -S qt5-webengine quota-tools --noconfirm --needed
        # for plasma-desktop
        pacman -S kaccounts-integration kscreen --noconfirm --needed
        # for plasma-vault
        pacman -S cryfs encfs gocryptfs --noconfirm --needed
        # for plasma-workspace
        pacman -S appmenu-gtk-module gpsd --noconfirm --needed
        # for kde-gtk-config
        pacman -S gnome-themes-extra --noconfirm --needed
        # for gtk tray icons
        pacman -S libappindicator-gtk2 libappindicator-gtk3 --noconfirm --needed
        # various nice-to-haves
        pacman -S kdialog --noconfirm --needed
        # configure sddm
        mkdir -p /etc/sddm.conf.d/
        cat <<EOF >/etc/sddm.conf.d/kde_settings.conf
[Theme]
Current=breeze
CursorTheme=breeze_cursors
EOF
        systemctl enable sddm
        ;;
    2)
        pacman -S gnome gnome-tweaks xdg-desktop-portal-gnome gnome-software-packagekit-plugin gnome-shell-extension-appindicator libappindicator-gtk2 libappindicator-gtk3 seahorse gvfs-goa dconf-editor gnome-themes-extra gnome-shell-extensions webp-pixbuf-loader python-nautilus fwupd --noconfirm --needed
        systemctl enable gdm
        sudo -u ${username} paru -S chrome-gnome-shell gnome-shell-extension-gsconnect gnome-shell-extension-dash-to-dock --noconfirm --needed
        # install breeze theme for apps like kdenlive
        pacman -S breeze --noconfirm --needed
        ;;
    3)
        curl --output /home/${username}/gnome-configure.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/gnome-configure.sh
        sed -i "/set -xe/a username='${username}'" /home/${username}/gnome-configure.sh
        sh /home/${username}/gnome-configure.sh
        rm /home/${username}/gnome-configure.sh
        ;;
    4)
        curl --create-dirs --output /home/${username}/.config/monitors.xml https://raw.githubusercontent.com/richard96292/ALIS/master/configs/monitors.xml
        sudo -u gdm curl --create-dirs --output /var/lib/gdm/.config/monitors.xml https://raw.githubusercontent.com/richard96292/ALIS/master/configs/monitors.xml
        ;;
    5)
        curl --output /home/${username}/.vimrc https://raw.githubusercontent.com/richard96292/ALIS/master/configs/.vimrc
        curl --output /home/${username}/.pam_environment https://raw.githubusercontent.com/richard96292/ALIS/master/configs/.pam_environment
        ;;
    6)
        cat <<EOF >/etc/X11/xorg.conf.d/50-mouse-acceleration.conf
Section "InputClass"
	Identifier "My Mouse"
	Driver "libinput"
	MatchIsPointer "yes"
	Option "AccelProfile" "flat"
	Option "AccelSpeed" "0"
EndSection
EOF
        ;;
    7)
        pacman -S power-profiles-daemon python-gobject --noconfirm --needed
        ;;
    8)
        pacman -S tlp ethtool smartmontools --noconfirm --needed
        sudo -u ${username} paru -S tlpui --noconfirm --needed
        systemctl enable tlp.service
        ;;
    9)
        pacman -S tlp-rdw --noconfirm --needed
        systemctl enable NetworkManager-dispatcher.service
        systemctl mask systemd-rfkill.service
        systemctl mask systemd-rfkill.socket
        ;;
    10)
        rm /lib/firmware/iwlwifi-ty-a0-gf-a0-6{6,7,8}.ucode.xz
        ;;
    11)
        echo "blacklist mei_me" >>/etc/modprobe.d/blacklist.conf
        ;;
    esac
done

for choice in ${choicesApplications}; do
    case ${choice} in
    devel)
        pacman -S git gcc gdb clang llvm lldb openmp python cmake ninja meson doxygen --noconfirm --needed
        ;;
    flatseal)
        flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal
        ;;
    firefox)
        pacman -S firefox firefox-ublock-origin --noconfirm --needed
        ;;
    fragments)
        pacman -S fragments --noconfirm --needed
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
    spotify)
        flatpak install -y --noninteractive flathub com.spotify.Client
        ;;
    keepassxc)
        pacman -S keepassxc xclip wl-clipboard --noconfirm --needed
        curl --create-dirs --output /home/${username}/.config/keepassxc/keepassxc.ini https://raw.githubusercontent.com/richard96292/ALIS/master/configs/keepassxc.ini
        ;;
    bitwarden)
        # flatpak install -y --noninteractive flathub com.bitwarden.desktop
        pacman -S bitwarden --noconfirm --needed
        ;;
    thunderbird)
        pacman -S thunderbird libnotify --noconfirm --needed
        ;;
    qbittorrent)
        pacman -S qbittorrent --noconfirm --needed
        ;;
    code)
        pacman -S code --noconfirm --needed
        ;;
    code-unlock)
        sudo -u ${username} paru -S code-features code-marketplace code-icons --noconfirm --needed
        ;;
    code-dotfiles)
        chown -R ${username}:${username} /home/${username}
        pkglist=(
            cschlosser.doxdocgen
            dbaeumer.vscode-eslint
            eamodio.gitlens
            esbenp.prettier-vscode
            formulahendry.code-runner
            foxundermoon.shell-format
            GitHub.vscode-pull-request-github
            haskell.haskell
            jeff-hykin.better-cpp-syntax
            justusadam.language-haskell
            mads-hartmann.bash-ide-vscode
            mhutchie.git-graph
            ms-azuretools.vscode-docker
            ms-python.python
            ms-python.vscode-pylance
            ms-toolsai.jupyter
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            ms-vscode.cmake-tools
            ms-vscode.cpptools
            twxs.cmake
            vscode-icons-team.vscode-icons
        )

        for i in ${pkglist[@]}; do
            sudo -u ${username} code --install-extension $i
        done

        curl --create-dirs --output "/home/${username}/.config/Code - OSS/User/settings.json" https://raw.githubusercontent.com/richard96292/ALIS/master/configs/settings.json
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
        sudo -u ${username} paru -S timeshift --noconfirm --needed
        ;;
    timeshift-autosnap)
        sudo -u ${username} paru -S timeshift-autosnap --noconfirm --needed
        ;;
    clion)
        sudo -u ${username} paru -S clion clion-cmake clion-gdb clion-lldb clion-jre --noconfirm --needed
        ;;
    discord)
        pacman -S discord --noconfirm --needed
        ;;
    discord-flatpak)
        flatpak install -y --noninteractive flathub dcom.discordapp.Discord
        ;;
    telegram)
        pacman -S telegram-desktop webkit2gtk --noconfirm --needed
        ;;
    element)
        pacman -S element-desktop --noconfirm --needed
        ;;
    onlyoffice)
        sudo -u ${username} paru -S onlyoffice-bin --noconfirm --needed
        ;;
    libreoffice)
        pacman -S libreoffice-fresh --noconfirm --needed
        ;;
    flacon)
        sudo -u ${username} paru -S flacon flac lame mac opus-tools sox vorbis-tools vorbisgain wavpack --noconfirm --needed
        ;;
    helvum)
        pacman -S helvum --noconfirm --needed
        ;;
    easyeffects)
        flatpak install -y --noninteractive flathub com.github.wwmm.easyeffects
        ;;
    jamesdsp)
        sudo -u ${username} paru -S jamesdsp --noconfirm --needed
        ;;
    gitg)
        pacman -S gitg --noconfirm --needed
        ;;
    esac
done

for choice in ${choicesGaming}; do
    case ${choice} in
    wine)
        pacman -S wine-staging wine-gecko wine-nine wine-mono winetricks --noconfirm --needed
        # additional dependencies (taken from lutris docs https://github.com/lutris/docs/blob/master/WineDependencies.md)
        sudo pacman -S --needed vkd3d lib32-vkd3d giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader lib32-gst-plugins-base lib32-gst-plugins-good lib32-libcups --noconfirm --needed
        ;;
    mangohud)
        sudo -u ${username} paru -S mangohud lib32-mangohud --noconfirm --needed
        curl --create-dirs --output /home/${username}/.config/MangoHud/MangoHud.conf https://raw.githubusercontent.com/richard96292/ALIS/master/configs/MangoHud.conf
        curl --create-dirs --output /home/${username}/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf https://raw.githubusercontent.com/richard96292/ALIS/master/configs/MangoHud.conf
        ;;
    gamemode)
        pacman -S gamemode lib32-gamemode --noconfirm --needed
        groupadd gamemode
        usermod -a -G gamemode ${username}
        curl --create-dirs --output /home/${username}/.config/gamemode.ini https://raw.githubusercontent.com/FeralInteractive/gamemode/master/example/gamemode.ini
        ;;
    steam)
        pacman -S steam --noconfirm --needed
        sudo -u ${username} paru -S proton-ge-custom-bin --noconfirm --needed
        ;;
    steam-flatpak)
        flatpak install -y --noninteractive flathub com.valvesoftware.Steam com.valvesoftware.Steam.CompatibilityTool.Proton-GE org.freedesktop.Platform.VulkanLayer.MangoHud com.valvesoftware.Steam.Utility.gamescope
        flatpak override --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam
        flatpak override --env=MANGOHUD=1 com.valvesoftware.Steam
        ;;
    goverlay)
        sudo -u ${username} paru -S goverlay-bin --noconfirm --needed
        ;;
    lutris)
        pacman -S lutris --noconfirm --needed
        ;;
    lutris-flatpak)
        flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
        flatpak install -y --noninteractive flathub-beta net.lutris.Lutris//beta
        flatpak install -y --noninteractive flathub org.gnome.Platform.Compat.i386 org.freedesktop.Platform.GL32.default org.freedesktop.Platform.GL.default
        ;;
    gamescope)
        pacman -S gamescope --noconfirm --needed
        ;;
    esac
done

# fix permissions
chown -R ${username}:${username} /home/${username}

# edit /etc/sudoers (there is 2 different variants)
sed -i "s/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
sed -i "s/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

pacman -Syu --noconfirm

rm -rf /root/post-archinstall.sh

# the most important step
pacman -S neofetch --noconfirm --needed
clear
neofetch
sleep 5

dialog --title "Congratulations" --yes-label "Reboot" --no-label "Cancel" --yesno "The installation has finished succesfully!\\n\\nDo you want to reboot your computer now?" 0 0
reboot
