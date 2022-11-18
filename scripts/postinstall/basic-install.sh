#!/bin/bash

function createUser() {
  # get username
  while true; do
    username=$(whiptail --title "Username" --nocancel --inputbox "${invalidMessage}Enter the username:" 0 0 3>&1 1>&2 2>&3)
    [[ "${username}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]] && break
    invalidMessage="The username is invalid.\nValid username should contain up to 32 lowercase letters, number, underscores and hyphens.\n"
  done

  # get password
  while true; do
    userPassword=$(whiptail --nocancel --passwordbox --title "Root password" "${invalidPasswordMessage}Enter the root password:" 10 50 3>&1 1>&2 2>&3)
    userPassword2=$(whiptail --nocancel --passwordbox --title "Confirm root password" "Retype the root password:" 10 50 3>&1 1>&2 2>&3)
    [[ "${userPassword}" == "${userPassword2}" && -n "${userPassword}" && -n "${userPassword2}" ]] && break
    invalidPasswordMessage="The passwords did not match or you have entered an empty password.\n\n"
  done
  clear

  # create a user
  # handle the case when user exists
  ! { id -u "${username}" >/dev/null 2>&1; } \
    || {
      whiptail --title "WARNING" --yes-button "Continue" \
        --no-button "Cancel" \
        --yesno "The user \`${username}\` already exists on this system." 14 70 || error "User exited."
    }
  useradd -m -g wheel "${username}" \
    || usermod -aG wheel "${username}" && mkdir -pv "/home/${username}" && chown "${username}:${username}"
  echo "${username}:${userPassword}" | chpasswd
  unset userPassword userPassword2
}

createUser

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
pacman -S asp bat --noconfirm --needed
sudo -u "$username" git clone https://aur.archlinux.org/paru-bin.git "/home/${username}/paru-bin"
cd "/home/${username}/paru-bin" || error "Paru directory does not exist."
sudo -u "$username" makepkg -si --noconfirm --needed
rm -rf "/home/${username}/paru-bin"
sed -i "s/#BottomUp/BottomUp/" /etc/paru.conf

# some basic things
pacman -S git htop bash-completion vim neovim \
  mesa mesa-utils lib32-mesa lib32-mesa-utils vulkan-icd-loader lib32-vulkan-icd-loader libva-utils \
  dosfstools ntfs-3g btrfs-progs libusb usbutils usbguard libusb-compat mtools efibootmgr \
  openssh sshfs rsync nfs-utils avahi cifs-utils \
  cronie curl wget inetutils net-tools nss-mdns \
  wl-clipboard xclip \
  xdg-utils xdg-user-dirs trash-cli \
  man-db man-pages texinfo \
  pacman-contrib reflector \
  libdecor lsb-release \
  wireguard-tools \
  sof-firmware \
  flatpak flatpak-xdg-utils flatpak-builder elfutils patch xdg-desktop-portal-gtk --noconfirm --needed

flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal

# pipewire
pacman -S pipewire pipewire-audio pipewire-alsa pipewire-docs pipewire-pulse pipewire-jack pipewire-x11-bell wireplumber wireplumber-docs \
  pipewire-v4l2 pipewire-zeroconf gst-plugin-pipewire \
  rtkit realtime-privileges \
  lib32-pipewire lib32-pipewire-jack lib32-pipewire-v4l2 --noconfirm --needed

# add user to realtime group (required by realtime-privileges)
usermod -aG realtime "$username"

# i like muh codecs
pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-bad-libs gst-plugins-ugly --noconfirm --needed
# i really like muh codecs
pacman -S jasper libpng libtiff libwebp libavif libheif libjxl libopenraw librsvg libwmf webp-pixbuf-loader --noconfirm --needed
pacman -S ffmpeg av1an svt-av1 aom dav1d rav1e x265 libde265 x264 xvidcore libvpx rav1e libmatroska mkvtoolnix-cli --noconfirm --needed
pacman -S lame libmad opus libvorbis speex faac faad2 --noconfirm --needed

# fonts
pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-croscore \
  cantarell-fonts ttf-opensans \
  ttf-fira-code woff2-fira-code ttf-fira-mono otf-fira-mono ttf-fira-sans otf-fira-sans \
  ttf-cascadia-code woff2-cascadia-code otf-cascadia-code \
  ttf-jetbrains-mono \
  gentium-plus-font \
  gnu-free-fonts ttf-liberation inter-font \
  ttf-ibm-plex ttf-ubuntu-font-family \
  ttf-caladea ttf-roboto ttf-roboto-mono ttf-inconsolata \
  ttf-font-awesome otf-font-awesome \
  libertinus-font tex-gyre-fonts otf-latin-modern otf-latinmodern-math \
  adobe-source-code-pro-fonts adobe-source-serif-fonts adobe-source-sans-fonts \
  ttf-junicode --noconfirm --needed

# zram
pacman -S zram-generator --noconfirm --needed
echo "[zram0]" >/etc/systemd/zram-generator.conf
echo "zram-size = min(ram / 2, 4096)" >>/etc/systemd/zram-generator.conf
systemctl daemon-reload
systemctl start /dev/zram0
zramctl

# avahi name resolution
sed -i "s/mymachines /&mdns_minimal [NOTFOUND=return] /" /etc/nsswitch.conf
systemctl enable avahi-daemon.service

# TODO: find a way for user to specify a country
cat <<EOF >/etc/xdg/reflector/reflector.conf
--save /etc/pacman.d/mirrorlist
--country Finland,Denmark,Germany,
--protocol https
--latest 5
EOF
systemctl enable reflector.timer

# enable cron
systemctl enable cronie.service

# discard unused packages in cache
systemctl enable paccache.timer
