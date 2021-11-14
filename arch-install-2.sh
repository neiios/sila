#!/usr/bin/env bash

read -r -p "Enter computer name:" hostname
echo $hostname > /etc/hostname

echo "Setting root password"
passwd

read -r -p "Enter a new user name:" username
useradd -m -G wheel libvirt -s /bin/bash $username
passwd $username
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo "setting up system..."

ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
# hwclock --systohc # most likely not needed (fixes time difference with windows)

# locale
sed 's/^#en_US\.UTF-8/en_US\.UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# install all this shit
pacman -S mesa lib32-mesa grub grub-btrfs efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober

# install grub and generate config
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB 
grub-mkconfig -o /boot/grub/grub.cfg

# enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

# the remaining configuration will happen after reboot
echo "Second script has finished successfully"
