#!/bin/bash

function tutorial() {
  # tutorial
  dialog --erase-on-exit \
    --title "A friendly reminder" \
    --msgbox "Up/Down arrows - navigate the list\nLeft/Right arrows or Tab - move to different parts of the dialog box\nEnter - confirm the dialog box\nSpace - toggle the selected item" 0 0
}

tutorial

cmdGeneral=(dialog --erase-on-exit --stdout --separate-output --nocancel
  --title "Packages"
  --checklist "Select packages to install (defaults are fine in most cases):" 0 0 0)
optionsGeneral=(
  bluetooth "Bluetooth support" on
  cups "Printing support (CUPS)" on
  vm "Virtual machines. Probably don't install on a laptop." on
  c "C/C++ dev tools." on
  rust "Rust dev tools." on
  java "Java dev tools." on
  js "Javascript dev tools." on
  python "Python dev tools." on
  go "Go dev tools." on
  ruby "Ruby dev tools." on
  assembly "Assembly dev tools." on
  misc "Other languages (lisp, vala, R, nim, zig et al)." off
  podman "The better container engine (recommended)" on
  docker "The OG container engine" off
)
choicesGeneral=$("${cmdGeneral[@]}" "${optionsGeneral[@]}")

cmdDesktop=(dialog --erase-on-exit --stdout --nocancel
  --title "Desktop environment"
  --menu "Select the DE you want to install:\nNothing is an option as well.\nYou can always install a DE or a WM from your dotfiles later." 0 0 0)
optionsDesktop=(
  gnome "GNOME"
  kde "KDE Plasma"
  none "Select if you want to install DE or WM from your dotfiles."
)
choicesDesktop=$("${cmdDesktop[@]}" "${optionsDesktop[@]}")

for choice in ${choicesGeneral}; do
  case ${choice} in
    bluetooth)
      pacman -S bluez bluez-utils --noconfirm --needed
      systemctl enable bluetooth.service
      ;;
    cups)
      pacman -S cups cups-pdf cups-pk-helper cups-filters \
        ghostscript gsfonts \
        foomatic-db-engine foomatic-db foomatic-db-ppds \
        foomatic-db-nonfree foomatic-db-nonfree-ppds \
        gutenprint foomatic-db-gutenprint-ppds system-config-printer --noconfirm --needed
      systemctl enable cups.socket
      ;;
    vm)
      yes y | pacman -S iptables-nft
      pacman -S virt-manager qemu libvirt \
        samba dnsmasq dmidecode bridge-utils openbsd-netcat --noconfirm --needed
      systemctl enable --now libvirtd.service
      virsh net-autostart default
      usermod -aG libvirt "${username:?Username not set.}"
      ;;
    c)
      pacman -S gcc gdb make pkgconf clang llvm lldb \
        openmp openmpi cmake ninja meson doxygen gtest elfutils \
        qt5 qt6 gtk3 gtk3-docs gtk3-demos gtk4 gtk4-docs gtk4-demos --noconfirm --needed
      ;;
    rust)
      pacman -S rust --noconfirm --needed
      ;;
    java)
      pacman -S jre-openjdk jdk-openjdk openjdk-doc openjdk-src \
        java-openjfx java-openjfx-doc java-openjfx-src \
        maven gradle ant \
        kotlin --noconfirm --needed
      ;;
    js)
      pacman -S nodejs npm yarn --noconfirm --needed
      ;;
    python)
      pacman -S python python-pip python-pipx \
        python-pipenv bpython jupyterlab jupyter-notebook --noconfirm --needed
      ;;
    go)
      pacman -S go gopls go-tools delve --noconfirm --needed
      ;;
    ruby)
      pacman -S ruby ruby-irb ruby-rdoc ruby-docs --noconfirm --needed
      ;;
    assembly)
      pacman -S binutils fasm nasm yasm --noconfirm --needed
      ;;
    misc)
      pacman -S nim lua r gcc-fortran zig vala \
        clisp ecl clojure leiningen ocaml erlang elixir --noconfirm --needed
      ;;
    podman)
      pacman -S podman podman-compose buildah \
        netavark cni-plugins \
        qemu-user-static qemu-user-static-binfmt \
        fuse-overlayfs slirp4netns --noconfirm --needed
      sed -i "s/driver = \"overlay\"/driver = \"btrfs\"/" /etc/containers/storage.conf
      ;;
    docker)
      pacman -S docker docker-compose python-docker --noconfirm --needed
      systemctl enable docker
      usermod -aG docker "${username:?Username not set.}"
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
      pacman -S power-profiles-daemon --noconfirm --needed
      # for kde-gtk-config
      pacman -S gnome-themes-extra --noconfirm --needed
      # for gtk tray icons
      pacman -S libappindicator-gtk2 libappindicator-gtk3 --noconfirm --needed
      # various nice-to-haves
      pacman -S kdialog --noconfirm --needed
      # flatpak theme
      flatpak install -y --noninteractive --system flathub org.gtk.Gtk3theme.Breeze
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
      pacman -S gnome xdg-desktop-portal-gnome gnome-tweaks lollypop \
        gnome-themes-extra python-nautilus \
        libappindicator-gtk2 libappindicator-gtk3 \
        breeze \
        power-profiles-daemon --noconfirm --needed
      pacman -Rns gnome-user-docs yelp gnome-maps gnome-contacts gnome-music --noconfirm || echo "You can fail, that's okay."
      systemctl enable gdm
      flatpak install -y --noninteractive --system flathub io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager
      # need to have dbus session for this to work
      cp /root/sila/scripts/postinstall/gnome-configure.sh /tmp/gnome-configure.sh
      chown "${username}:${username}" /tmp/gnome-configure.sh
      sudo -u "${username}" dbus-run-session -- bash /tmp/gnome-configure.sh
      ;;
  esac
done
