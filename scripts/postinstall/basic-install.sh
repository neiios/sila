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
    userPassword=$(whiptail --nocancel --passwordbox --title "User password" "${invalidPasswordMessage}Enter the user password:" 10 50 3>&1 1>&2 2>&3)
    userPassword2=$(whiptail --nocancel --passwordbox --title "Confirm user password" "Retype the user password:" 10 50 3>&1 1>&2 2>&3)
    [[ "${userPassword}" == "${userPassword2}" && -n "${userPassword}" && -n "${userPassword2}" ]] && break
    invalidPasswordMessage="The passwords did not match or you have entered an empty password.\n\n"
  done
  clear

  # create a user
  useradd -m "${username}"
  usermod -aG wheel "${username}"
  echo "${username}:${userPassword}" | chpasswd
  unset userPassword userPassword2
}

function setTimezone() {
  hwclock --systohc
  arr=("Europe/Vilnius" "Timezone")
  while read -r timezone; do
    arr+=("${timezone}" "Timezone")
  done <<<"$(timedatectl list-timezones)"
  cmd=(whiptail --nocancel --title "Timezone" --menu "Select a timezone from the list:" 32 50 24)
  chosenTimezone=$("${cmd[@]}" "${arr[@]}" 2>&1 >/dev/tty)
  timedatectl set-timezone "${chosenTimezone}"
}

createUser || errror "Failed to create a user."

setTimezone || error "Failed to set a timezone."

# configure pacman
sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -i "s/^#VerbosePkgLists/VerbosePkgLists/" /etc/pacman.conf
sed -i "s/^#Color/Color/" /etc/pacman.conf
sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 5/" /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Syy

# configure make
sed -i "s/-j2/-j$(($(nproc) - 1))/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# install paru
pacman -S asp bat --noconfirm --needed
sudo -u "$username" git clone https://aur.archlinux.org/paru-bin.git "/home/${username}/paru-bin"
cd "/home/${username}/paru-bin" || error "Paru directory does not exist."
sudo -u "$username" makepkg -si --noconfirm --needed
rm -rf "/home/${username}/paru-bin"
sed -i "s/#BottomUp/BottomUp/" /etc/paru.conf

# some basic things
pacman -S git htop bash-completion neovim \
  mesa mesa-utils lib32-mesa lib32-mesa-utils vulkan-icd-loader lib32-vulkan-icd-loader libva-utils \
  dosfstools ntfs-3g btrfs-progs libusb usbutils usbguard libusb-compat mtools efibootmgr \
  openssh gvfs sshfs rsync nfs-utils avahi cifs-utils \
  cronie curl wget inetutils net-tools nss-mdns \
  wl-clipboard xclip \
  xdg-utils xdg-user-dirs trash-cli \
  man-db man-pages texinfo \
  pacman-contrib \
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
pacman -S jasper libpng libraw libtiff libwebp libavif libheif libjxl libopenraw librsvg libwmf webp-pixbuf-loader kimageformats karchive qt5-imageformats --noconfirm --needed
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

# mirrorlist
sudo -u "${username}" paru -S rate-mirrors-bin --noconfirm --needed
sudo -u "${username}" rate-mirrors --save=/tmp/mirrorlist --protocol=https arch --max-delay=21600
mv /etc/pacman.d/mirrorlist{,.backup}
mv /tmp/mirrorlist /etc/pacman.d/mirrorlist
# add alias
cat <<'EOF' >>/etc/bashrc
alias rate-mirrors-arch='export TMPFILE="$(mktemp)"; \
  rate-mirrors --save=$TMPFILE --protocol=https arch --max-delay=21600 \
    && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup \
    && sudo mv $TMPFILE /etc/pacman.d/mirrorlist'
EOF

# enable cron
systemctl enable cronie.service

# discard unused packages in cache
systemctl enable paccache.timer
