#!/usr/bin/env bash
set -xe

# ----------------------------- hosts -----------------------------
read -r -p "Enter computer name:" hostname
echo $hostname >/etc/hostname
echo "127.0.0.1 localhost" >>/etc/hosts
echo "::1       localhost" >>/etc/hosts
echo "127.0.1.1" ${hostname}".localdomain" ${hostname} >>/etc/hosts
# ----------------------------- hosts -----------------------------

# ----------------------------- root password -----------------------------
echo "Setting root password"
passwd
# ----------------------------- root password -----------------------------

read -r -p "Enter a new user name:" username
useradd -m $username
usermod -aG wheel $username

echo "Set password for ${username}"
passwd ${username}
echo "%wheel ALL=(ALL) ALL" >>/etc/sudoers

echo "user ${username} created"

ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
hwclock --systohc

# ----------------------------- locale -----------------------------
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >>/etc/locale.gen
echo "lt_LT.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf
echo "Locale generated"
# ----------------------------- locale -----------------------------

# TODO: i dont have to use ntfs-3g now
yes y | pacman -S iptables-nft
pacman -S mesa grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils cups alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call libvirt virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat ipset flatpak sof-firmware nss-mdns acpid os-prober wireplumber curl wget ntfs-3g usbutils --noconfirm

# ----------------------------- bluetooth -----------------------------
pacman -S bluez bluez-utils
# ----------------------------- bluetooth -----------------------------

# If installing with btrfs
# pacman -S grub-btrfs btrfs-progs

# AMD ucode
pacman -S amd-ucode
# Intel ucode
# pacman -S intel-ucode

# installing vulkan drivers (AMD)
pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
# installing vulkan drivers (NVIDIA)
# pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
# installing vulkan drivers (Intel)
# pacman -S lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm

systemctl enable paccache.timer
# power management (for a laptop)
# pacman -S tlp --noconfirm

# ----------------------------- printers -----------------------------
pacman -S cups ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds gutenprint foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds --noconfirm

# ------------- for qt environments -------------
pacman -S print-manager --noconfirm
# ------------- for qt environments -------------

# ------------- hp printers -------------
# pacman -S hplip python-pyqt5 --noconfirm
# ------------- hp printers -------------

systemctl enable cups.socket
systemctl enable cups.service
# ----------------------------- printers -----------------------------

# ----------------------------- firewall -----------------------------
pacman -S ufw ufw-extras
systemctl enable ufw.service
ufw default allow outgoing
ufw default deny incoming
ufw allow "KDE Connect"
ufw enable
# ----------------------------- firewall -----------------------------

usermod -aG libvirt $username
echo "Packages installed"

# install grub and generate config
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >>/etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub configured"

# bootctl install
# echo "Systemd-boot configured"

# enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sshd
systemctl enable avahi-daemon
# systemctl enable reflector.service
# systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable acpid

echo "Second script has finished successfully"
