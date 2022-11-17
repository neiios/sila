#!/bin/bash

# desktop input
cmd=(whiptail --separate-output --checklist "Select basic packages to install (you most likely want all of them):" 32 96 24)
optionsGeneral=(
  bluetooth "Bluetooth support" on
  cups "Printing support (CUPS)" on
  devel "A lot of development tools for various programming languages" on
  vm "Virtual machines (Qemu+KVM)" on
  podman "The better container engine (recommended)" on
  docker "The OG container engine" off
)
choicesGeneral=$("${cmd[@]}" "${optionsGeneral[@]}" 2>&1 >/dev/tty)

cmdDesktop=(whiptail --separate-output --checklist "Select the desktop environment you want to install:\n\nNothing is an option as well.\n\nYou can install a desktop from your dotfiles later." 32 96 24)
optionsDesktop=(
  gnome "GNOME" off
  gnome-additional-apps "Some additional apps (can be installed later)" off
  kde "KDE Plasma" off
)

choicesDesktop=$("${cmdDesktop[@]}" "${optionsDesktop[@]}" 2>&1 >/dev/tty)
clear

for choice in ${choicesGeneral}; do
  case ${choice} in
  devel)
    # TODO: https://wiki.archlinux.org/title/Java#Better_font_rendering
    pacman -S git \
      python \
      gcc gdb make pkgconf clang llvm lldb openmp cmake ninja meson doxygen elfutils \
      rust \
      ruby ruby-docs \
      jre-openjdk jdk-openjdk openjdk-src java-openjfx java-openjfx-src \
      vala \
      eslint prettier npm nodejs --noconfirm --needed
    ;;
  docker)
    pacman -S docker docker-compose python-docker --noconfirm --needed
    systemctl enable docker
    usermod -aG docker "$username"
    ;;
  podman)
    pacman -S podman podman-compose buildah \
      netavark cni-plugins \
      qemu-user-static qemu-user-static-binfmt \
      fuse-overlayfs slirp4netns --noconfirm --needed
    ;;
  bluetooth)
    pacman -S bluez bluez-utils --noconfirm --needed
    systemctl enable bluetooth.service
    ;;
  vm)
    yes y | pacman -S virt-manager qemu-full iptables-nft libvirt dnsmasq dmidecode bridge-utils openbsd-netcat
    systemctl enable libvirtd.service
    # TODO: create a default network and start it. Create a default storage pool.
    usermod -aG libvirt "${username}"
    ;;
  cups)
    pacman -S cups cups-pdf cups-pk-helper cups-filters \
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
    # color power
    pacman -S colord-kde --noconfirm --needed
    # kcms
    pacman -S sddm-kcm kde-gtk-config --noconfirm --needed
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
    # power profiles daemon
    pacman -S power-profiles-daemon python-gobject --noconfirm --needed
    # for kde-gtk-config
    pacman -S gnome-themes-extra --noconfirm --needed
    # for gtk tray icons
    pacman -S libappindicator-gtk2 libappindicator-gtk3 --noconfirm --needed
    # various nice-to-haves
    pacman -S kdialog --noconfirm --needed
    # flatpak theme
    flatpak install -y --noninteractive flathub org.gtk.Gtk3theme.Breeze
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
    pacman -S gnome-shell-extensions gnome-system-monitor gnome-disk-utility gnome-terminal lollypop gnome-software gnome-user-share nautilus simple-scan sushi tracker tracker3-miners tracker-miners xdg-user-dirs-gtk gnome-tweaks seahorse dconf-editor rygel gnome-color-manager cheese eog evince file-roller totem gnome-remote-desktop --noconfirm --needed
    # tray icons
    pacman -S gnome-shell-extension-appindicator libappindicator-gtk2 libappindicator-gtk3 --noconfirm --needed
    # you do need this, right?
    pacman -S gnome-calculator gnome-calendar gnome-clocks --noconfirm --needed
    # other
    pacman -S gnome-themes-extra gnome-backgrounds gnome-video-effects webp-pixbuf-loader python-nautilus --noconfirm --needed
    # gvfs and grilo
    pacman -S grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb --noconfirm --needed
    # install breeze theme (some kde apps look really bad without it and dont seem to require it as a dep)
    pacman -S breeze --noconfirm --needed
    # power profiles daemon
    pacman -S power-profiles-daemon python-gobject --noconfirm --needed
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
    pacman -S baobab gnome-books gnome-characters gnome-font-viewer gnome-logs gnome-photos gnome-weather --noconfirm --needed
    ;;
  esac
done
