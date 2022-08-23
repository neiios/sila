#!/bin/bash

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
    curl --create-dirs --output /home/${username}/.config/MangoHud/MangoHud.conf https://raw.githubusercontent.com/richard96292/alis/master/configs/MangoHud.conf
    curl --create-dirs --output /home/${username}/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf https://raw.githubusercontent.com/richard96292/alis/master/configs/MangoHud.conf
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
