#!/bin/bash

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
clear

for choice in ${choicesGeneral}; do
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
  bluetooth)
    pacman -S bluez bluez-utils --noconfirm --needed
    systemctl enable bluetooth.service
    ;;
  vm)
    yes y | pacman -S virt-manager qemu-full iptables-nft libvirt dnsmasq dmidecode bridge-utils openbsd-netcat
    systemctl enable libvirtd.service
    usermod -aG libvirt "${username}"
    ;;
  cups)
    pacman -S cups cups-pk-helper cups-filters cups-pdf \
      ghostscript gsfonts \
      foomatic-db-engine foomatic-db foomatic-db-ppds \
      foomatic-db-nonfree foomatic-db-nonfree-ppds \
      gutenprint foomatic-db-gutenprint-ppds system-config-printer --noconfirm --needed
    systemctl enable cups.socket
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
    pacman -S ffmpegthumbs kdegraphics-thumbnailers kdenetwork-filesharing audiocd-kio kio-zeroconf --noconfirm --needed
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
    # and some flatpaks
    flatpak install -y --noninteractive flathub io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager
    # set default settings/root/alis/scripts/postinstall/desktop.sh
    # shellcheck source=/scripts/postinstall/gnome-configure.sh
    source /root/alis/scripts/postinstall/gnome-configure.sh
    ;;
  gnome-additional-apps)
    # other apps
    pacman -S baobab gnome-books gnome-characters gnome-disk-utility gnome-font-viewer gnome-logs lollypop gnome-photos gnome-weather --noconfirm --needed
    ;;
  ppd)
    pacman -S power-profiles-daemon python-gobject --noconfirm --needed
    ;;
  tlp)
    pacman -S tlp ethtool smartmontools tlp-rdw --noconfirm --needed
    sudo -u "${username}" paru -S tlpui --noconfirm --needed
    systemctl enable tlp.service
    systemctl enable NetworkManager-dispatcher.service
    systemctl mask systemd-rfkill.service
    systemctl mask systemd-rfkill.socket
    ;;
  esac
done
