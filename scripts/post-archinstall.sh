#!/usr/bin/env bash
set -xe

# ----------------------------- paru -----------------------------
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf paru
# ----------------------------- paru -----------------------------

# ----------------------------- zram -----------------------------
sudo pacman -S zram-generator --noconfirm
sudo cp ~/script/configs/zram-generator.conf /etc/systemd/zram-generator.conf
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0
zramctl
# ----------------------------- zram -----------------------------

sudo pacman -Syy
sudo reflector --country Germany,Netherlands,Sweden,Finland,Denmark --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# install fonts
sudo pacman -S dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation libertinus-font noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts ttf-font-awesome adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-iosevka-nerd --noconfirm

# install asian fonts
sudo pacman -S wqy-zenhei adobe-source-han-serif-cn-fonts adobe-source-han-serif-jp-fonts adobe-source-han-serif-kr-fonts adobe-source-han-serif-otc-fonts adobe-source-han-serif-tw-fonts --noconfirm

# install kde
sudo pacman -S xorg plasma-meta kde-applications-meta sddm plasma-wayland-session --noconfirm
paru -S kmozillahelper plasma-browser-integration
sudo systemctl enable sddm

# ah, yes. neofetch
sudo pacman -S neofetch --noconfirm

# install zsh
# Make a folder for zsh history
mkdir -p ~/.cache/zsh/
sudo pacman -S zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting --noconfirm
chsh -s /bin/zsh

# install my applications
# TODO setup ssh-agent for keepassxc https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
sudo pacman -S firefox keepassxc wl-clipboard chromium obs-studio v4l2loopback-dkms libfdk-aac libva-mesa-driver thunderbird sshfs qbittorrent code trash-cli gimp kdenlive ffmpeg opencv easyeffects --noconfirm

# gnome-integration, appindicator, github-cli, timeshift and clion
paru -S chrome-gnome-shell github-cli timeshift clion gcc gdb cmake clion-jre doxygen --noconfirm

# copy my pacman.conf file
sudo cp ~/script/configs/pacman.conf /etc/pacman.conf
sudo pacman -Syy

# games
sudo pacman -S lib32-mesa wine-staging wine-mono wine-gecko winetricks vkd3d lib32-vkd3d lutris --noconfirm
paru -S mangohud lib32-mangohud goverlay --noconfirm

# not sure if that is really needed (taken from lutris docs https://github.com/lutris/docs/blob/master/WineDependencies.md)
sudo pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm

# install and configure gamemode
sudo pacman -S gamemode lib32-gamemode --noconfirm
sudo groupadd gamemode
sudo usermod -a -G gamemode $USER
sudo curl --output /usr/share/gamemode/gamemode.ini --create-dirs "https://raw.githubusercontent.com/FeralInteractive/gamemode/master/example/gamemode.ini"

# ----------------------------- flattak -----------------------------
sudo flatpak install -y --noninteractive flathub dcom.discordapp.Discord org.telegram.desktop org.onlyoffice.desktopeditors im.riot.Riot io.gitlab.librewolf-community

flatpak install com.valvesoftware.Steam com.valvesoftware.Steam.CompatibilityTool.Proton-GE org.freedesktop.Platform.VulkanLayer.MangoHud

flatpak override --user --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam
flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam
# ----------------------------- flatpak -----------------------------

# sudo flatpak override --user --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam

# Hiding desktop entries (doesnt work on kde)
echo "[Desktop Entry]
Hidden=true" >/tmp/1
mkdir -p ~/.local/share/applications/
find /usr -name "*lsp_plug*desktop" 2>/dev/null | cut -f 5 -d '/' | xargs -I {} cp -f /tmp/1 ~/.local/share/applications/{}

# ----------------------------- configs -----------------------------
cp ~/script/configs/.zshrc ~/.zshrc

mkdir -p ~/.config/easyeffects/output/
cp ~/script/configs/Audeze\ iSine\ 20\ Harman\ Oratory.json ~/.config/easyeffects/output/Audeze\ iSine\ 20\ Harman\ Oratory.json

cp ~/script/configs/.vimrc ~/.vimrc

mkdir -p ~/.config/MangoHud/
cp ~/script/configs/MangoHud.conf ~/.config/MangoHud/MangoHud.conf
cp ~/script/configs/MangoHud.conf ~/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf

cp ~/script/configs/20-amdgpu.conf /etc/X11/xorg.conf.d/20-amdgpu.conf

cp ~/script/configs/.pam_environment ~/.pam_environment

mkdir -p ~/.config/keepassxc/
cp ~/script/configs/keepassxc.ini ~/.config/keepassxc/keepassxc.ini
# ----------------------------- configs -----------------------------

# ----------------------------- gnome section -----------------------------
# sudo pacman -S gnome gnome-tweaks xdg-desktop-portal-gnome --noconfirm
# sudo systemctl enable gdm
# install breeze theme for apps like kdenlive
# sudo pacman -S breeze --noconfirm

# cp ~/script/configs/monitors.xml ~/.config/monitors.xml
# sudo mkdir -p /var/lib/gdm/.config/
# sudo cp ~/script/configs/monitors.xml /var/lib/gdm/.config/
# sudo chown gdm:gdm /var/lib/gdm/.config/monitors.xml

# ~/script/scripts/gnome-configure.sh
# ----------------------------- gnome section -----------------------------

# ----------------------------- drives -----------------------------
# sudo mkdir -p /run/media/$USER/nvme
# echo "/dev/nvme0n1p3 /run/media/$USER/nvme ntfs-3g defaults 0 0" | sudo tee -a /etc/fstab
# sudo mkdir -p /run/media/$USER/hdd
# echo "/dev/sdb1      /run/media/$USER/hdd  ntfs-3g defaults 0 0" | sudo tee -a /etc/fstab
# ----------------------------- drives -----------------------------

#reboot
echo "You can reboot now"
rm -rf ~/script
