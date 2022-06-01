#!/bin/bash
set -xe

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# vm check
if [ $(dmesg | grep "Hypervisor detected" | wc -l) -ne 0 ]; then
    echo "Virtual machine detected. Installing additional tools."
    pacman -S qemu-guest-agent spice-vdagent virtualbox-guest-utils --noconfirm --needed
    systemctl enable qemu-guest-agent.service
    sleep 5
fi

# install dependencies
pacman -Syyu dialog git curl archlinux-keyring --noconfirm --needed

# use sudo without password (should be reverted at the end of the script)
sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

# all inputs
curl --create-dirs --output /tmp/input.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/postinstall/input.sh && source /tmp/input.sh

# basic packages
curl --create-dirs --output /tmp/basic-install.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/postinstall/basic-install.sh && source /tmp/basic-install.sh

for choice in ${choicesGeneral}; do
    case ${choice} in
    1)
        yes y | pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pipewire-v4l2 pipewire-zeroconf gst-plugin-pipewire
        # multilib
        yes y | pacman -S lib32-pipewire lib32-pipewire-jack lib32-pipewire-v4l2
        ;;
    2)
        pacman -S bluez bluez-utils --noconfirm --needed
        systemctl enable bluetooth.service
        ;;
    3)
        yes y | pacman -S virt-manager qemu-full iptables-nft libvirt dnsmasq dmidecode bridge-utils openbsd-netcat
        systemctl enable libvirtd.service
        usermod -aG libvirt $username
        ;;
    6)
        pacman -S cups cups-pk-helper cups-filters cups-pdf ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds system-config-printer --noconfirm --needed
        systemctl enable cups.socket
        ;;
    7)
        # not tested (and probably never will be)
        pacman -S hplip python-pillow python-pyqt5 python-reportlab python-reportlab sane --noconfirm --needed
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
    gstreamer)
        # gstreamer (pulls all releveant codecs)
        pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-bad-libs gst-plugins-ugly --noconfirm --needed
        ;;
    flatpak)
        pacman -S flatpak flatpak-xdg-utils flatpak-builder elfutils patch xdg-desktop-portal-gtk --noconfirm --needed
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
    kde)
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
        pacman -S fwupd --noconfirm --needed
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
    gnome)
        # essential
        pacman -S gnome-shell mutter gdm xdg-desktop-portal-gnome gnome-keyring gnome-control-center gnome-session gnome-menus gnome-settings-daemon --noconfirm --needed
        # basics
        pacman -S gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-software gnome-user-share nautilus simple-scan sushi tracker tracker3-miners tracker-miners xdg-user-dirs-gtk gnome-tweaks seahorse dconf-editor rygel gnome-color-manager cheese eog evince file-roller totem gnome-remote-desktop --noconfirm --needed
        # tray icons
        pacman -S gnome-shell-extension-appindicator libappindicator-gtk2 libappindicator-gtk3 --noconfirm --needed
        # you do need this, right?
        pacman -S gnome-calculator gnome-calendar gnome-clocks --noconfirm --needed
        # other
        pacman -S gnome-themes-extra gnome-backgrounds gnome-video-effects webp-pixbuf-loader python-nautilus --noconfirm --needed
        # gvfs and grilo
        pacman -S grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb --noconfirm --needed
        # install breeze theme and qt5ct to configure qt apps
        pacman -S breeze qt5ct --noconfirm --needed
        # enable gdm
        systemctl enable gdm
        # set default settings
        curl --create-dirs --output /tmp/gnome-configure.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/postinstall/gnome-configure.sh && source /tmp/gnome-configure.sh
        ;;
    gnome-additional-apps)
        # other apps
        pacman -S baobab gnome-books gnome-characters gnome-disk-utility gnome-font-viewer gnome-logs lollypop gnome-photos gnome-weather --noconfirm --needed
        ;;
    4)
        curl --create-dirs --output /home/${username}/.config/monitors.xml https://raw.githubusercontent.com/richard96292/ALIS/master/configs/monitors.xml
        sudo -u gdm curl --create-dirs --output /var/lib/gdm/.config/monitors.xml https://raw.githubusercontent.com/richard96292/ALIS/master/configs/monitors.xml
        ;;
    5)
        curl --output /home/${username}/.vimrc https://raw.githubusercontent.com/richard96292/ALIS/master/configs/.vimrc
        ;;
    7)
        pacman -S power-profiles-daemon python-gobject --noconfirm --needed
        ;;
    8)
        pacman -S tlp ethtool smartmontools tlp-rdw --noconfirm --needed
        sudo -u ${username} paru -S tlpui --noconfirm --needed
        systemctl enable tlp.service
        systemctl enable NetworkManager-dispatcher.service
        systemctl mask systemd-rfkill.service
        systemctl mask systemd-rfkill.socket
        ;;
    12)
        sudo -u ${username} paru -S adw-gtk3-git --noconfirm --needed
        sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
        ;;
    esac
done

# install fonts
curl --create-dirs --output /tmp/fonts.sh https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/postinstall/fonts.sh && source /tmp/fonts.sh

for choice in ${choicesApplications}; do
    case ${choice} in
    devel)
        # TODO: https://wiki.archlinux.org/title/Java#Better_font_rendering
        pacman -S git \
            python \
            gcc gdb clang llvm lldb openmp cmake ninja meson doxygen elfutils \
            rust \
            jre-openjdk jdk-openjdk openjdk-src java-openjfx java-openjfx-src \
            vala \
            eslint prettier npm nodejs \
            docker docker-compose --noconfirm --needed
        ;;
    flatseal)
        flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal
        ;;
    gnome-extension-manager)
        flatpak install -y --noninteractive flathub com.mattjakeman.ExtensionManager
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
    tauon)
        flatpak install -y --noninteractive flathub com.github.taiko2k.tauonmb
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
            piousdeer.adwaita-theme
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
        flatpak install -y --noninteractive flathub org.telegram.desktop
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
        pacman -S --needed vkd3d lib32-vkd3d giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader lib32-gst-plugins-base lib32-gst-plugins-good lib32-libcups --noconfirm --needed
        ;;
    mangohud)
        sudo -u ${username} paru -S mangohud mangoapp --noconfirm --needed
        sudo -u ${username} paru -S lib32-mangohud --noconfirm --needed
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
        ;;
    proton-ge)
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

for choice in ${choicesFixes}; do
    case ${choice} in
    ax210)
        rm /lib/firmware/iwlwifi-ty-a0-gf-a0-6{6,7,8}.ucode.xz
        ;;
    accel)
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
    mei_me)
        echo "blacklist mei_me" >>/etc/modprobe.d/blacklist.conf
        ;;
    esac
done

# fix permissions
chown -R ${username}:${username} /home/${username}

# revert sudoers file
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
