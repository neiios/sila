#!/bin/bash

# functions
function usernameInput() {
    while true; do
        u=$(whiptail --title "Username" --inputbox "${invalidMessage}Enter the username:" 0 0 3>&1 1>&2 2>&3)
        [[ "${u}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]] && echo "${u}" && break
        invalidMessage="The username is invalid.\nValid username should contain up to 32 lowercase letters, number, underscores and hyphens.\nThe username may end with a \$.\n"
    done
}

function inputPass() {
    while true; do
        t=$(whiptail --title "$1 password" --passwordbox "${invalidPasswordMessage}Enter the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        t2=$(whiptail --title "$1 password" --passwordbox "Retype the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        [[ "${t}" == "${t2}" ]] && [[ -n "${t}" ]] && [[ -n "${t2}" ]] && echo "${t}" && break
        # special case for disk encryption (it can be an empty string)
        [[ "${t}" == "${t2}" ]] && [[ "$1" == "Disk encryption" ]] && echo "${t}" && break
        invalidPasswordMessage="The passwords did not match or you have entered an empty string.\n\n"
    done
}

# get username and password
username=$(usernameInput)
password="$(inputPass "Regular user")"
clear

# create a user
useradd -m "${username}"
usermod -aG wheel "${username}"
echo "${username}:${password}" | chpasswd

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
git clone https://aur.archlinux.org/paru-bin.git "/home/${username}/paru-bin"
cd "/home/${username}/paru-bin" || exit
chown "${username}:${username}" "/home/${username}/paru-bin"
sudo -u "${username}" makepkg -si --noconfirm --needed
rm -rf "/home/${username}/paru-bin"
# currently paru has a nasty bug
# see: https://github.com/Morganamilo/paru/issues/631#issuecomment-998703406
# paru needs to be called from a directory owned by the current user
chown -R "${username}:${username}" "/home/${username}"
cd "/home/${username}" || exit

pacman -S htop bash-completion vim neovim \
  mesa mesa-utils lib32-mesa lib32-mesa-utils vulkan-icd-loader lib32-vulkan-icd-loader libva-utils \
  ntfs-3g dosfstools btrfs-progs libusb usbutils usbguard libusb-compat mtools efibootmgr \
  openssh sshfs rsync nfs-utils avahi \
  cronie curl wget inetutils net-tools nss-mdns \
  xdg-utils xdg-user-dirs trash-cli \
  man-db man-pages texinfo \
  pacman-contrib reflector \
  libdecor \
  sof-firmware \
  flatpak flatpak-xdg-utils flatpak-builder elfutils patch xdg-desktop-portal-gtk --noconfirm --needed

flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal

# pipewire
pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
  pipewire-v4l2 pipewire-zeroconf gst-plugin-pipewire pipewire-x11-bell \
  lib32-pipewire lib32-pipewire-jack lib32-pipewire-v4l2 \
  qpwgraph --noconfirm --needed

# i like muh codecs
pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-bad-libs gst-plugins-ugly --noconfirm --needed

# fonts
pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-croscore \
  cantarell-fonts \
  ttf-fira-code woff2-fira-code ttf-fira-mono otf-fira-mono ttf-fira-sans otf-fira-sans \
  ttf-cascadia-code woff2-cascadia-code otf-cascadia-code \
  ttf-jetbrains-mono \
  gentium-plus-font \
  gnu-free-fonts ttf-liberation inter-font \
  ttf-ibm-plex ttf-ubuntu-font-family \
  ttf-caladea ttf-roboto ttf-roboto-mono ttf-anonymous-pro ttf-inconsolata ttf-opensans \
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

systemctl enable avahi-daemon.service
sed -i "s/mymachines /&mdns_minimal [NOTFOUND=return] /" /etc/nsswitch.conf
systemctl enable cronie.service
systemctl enable reflector.timer
systemctl enable paccache.timer
# dont enable on an encrypted drive
# systemctl enable fstrim.timer
