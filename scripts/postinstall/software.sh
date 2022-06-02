#!/bin/bash

for choice in ${choicesApplications}; do
  case ${choice} in
  firefox)
    pacman -S firefox firefox-ublock-origin --noconfirm --needed
    ;;
  firefox-nightly)
    sudo -u ${username} paru -S firefox-nightly firefox-ublock-origin --noconfirm --needed
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
  fragments)
    pacman -S fragments --noconfirm --needed
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
