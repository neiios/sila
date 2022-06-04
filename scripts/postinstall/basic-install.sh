#!/bin/bash

# create a user
useradd -m ${username}
usermod -aG wheel ${username}
echo ${username}:${password} | chpasswd

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
git clone https://aur.archlinux.org/paru-bin.git /home/${username}/paru-bin
cd /home/${username}/paru-bin
chown ${username}:${username} /home/${username}/paru-bin
sudo -u ${username} makepkg -si --noconfirm --needed
rm -rf /home/${username}/paru-bin
# currently paru has a nasty bug
# see: https://github.com/Morganamilo/paru/issues/631#issuecomment-998703406
# paru needs to be called from a directory owned by the current user
chown -R ${username}:${username} /home/${username}
cd /home/${username}

pacman -S xorg htop bash-completion vim neovim \
  mesa mesa-utils lib32-mesa lib32-mesa-utils vulkan-icd-loader lib32-vulkan-icd-loader libva-utils \
  ntfs-3g dosfstools btrfs-progs libusb usbutils usbguard libusb-compat mtools efibootmgr \
  openssh sshfs rsync nfs-utils avahi \
  cronie curl wget inetutils net-tools nss-mdns \
  xdg-utils xdg-user-dirs trash-cli \
  man-db man-pages texinfo \
  pacman-contrib reflector \
  libdecor \
  sof-firmware --noconfirm --needed

systemctl enable avahi-daemon.service
sed -i "s/mymachines /&mdns_minimal [NOTFOUND=return] /" /etc/nsswitch.conf
systemctl enable cronie.service
systemctl enable reflector.timer
systemctl enable paccache.timer
# dont enable on an encrypted drive
# systemctl enable fstrim.timer
