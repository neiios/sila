#!/usr/bin/env bash

# install paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# install zramd
paru -S zramd
sed 's/^# MAX_SIZE=8192/MAX_SIZE=2048/' /etc/default/zramd
sudo systemctl enable --now zramd.service

sudo timedatectl set-ntp true
sudo reflector -a 12 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syu

# install fonts
sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji
# install asian fonts
sudo pacman -S wqy-zenhei adobe-source-han-serif-cn-fonts adobe-source-han-serif-jp-fonts adobe-source-han-serif-kr-fonts adobe-source-han-serif-otc-fonts adobe-source-han-serif-tw-fonts
# install plasma
sudo pacman -S plasma-meta plasma-wayland-session kde-applications-meta
sudo systemctl enable sddm

# install my applications
sudo pacman -S firefox 
sudo pacman -S keepassxc wl-clipboard
sudo pacman -S obs-studio v4l2loopback-dkms libfdk-aac libva-mesa-driver
sudo pacman -S thunderbird
sudo pacman -S kdeconnect sshfs qt5-tools
sudo pacman -S qbittorrent
sudo pacman -S code
sudo pacman -S gimp kdenlive ffmpeg opencv
sudo pacman -S easyeffects
echo "[Desktop Entry] Hidden=true" > /tmp/1
find /usr -name "*lsp_plug*desktop" 2> /dev/null | cut -f 5 -d '/' | xargs -I {} cp /tmp/1 ~/.local/share/applications/{}

# enable multilib
sed 's/^# [multilib]/[multilib]/' /etc/pacman.conf
sed 's/^# Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/' /etc/pacman.conf

# games
sudo pacman -S steam
paru -S mangohud lib32-mangohud goverlay proton-ge-custom-bin kdialog lib32-vulkan-icd-loader wine-ge-custom wine-mono wine-gecko winetricks

# install and configure gamemode
sudo pacman -S gamemode lib32-gamemode 
sudo groupadd gamemode
sudo usermod -a -G gamemode $USER
curl "https://raw.githubusercontent.com/FeralInteractive/gamemode/master/example/gamemode.ini" --output "/usr/share/$user/gamemode.ini"

#flatpak
flatpak install clion discord telegram

#reboot
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
