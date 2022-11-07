#!/bin/bash

cmdTweaks=(whiptail --title "Tweaks" --separate-output --checklist "Select the tweaks you want to apply:" 0 0 0)
optionsTweaks=(
    nm-wait-online "Makes boot time faster but not waiting for network connection" off
    ax210-firmware "AX210 firmware fix" off
    xorg-libinput-accel "Disable Mouse acceleration (Xorg override)" off
    mei_me "Blacklist mei_me kernel module" off
    ntfs "Use ntfs kernel kernel module by default" off
    sddm-wayland "Run sddm on wayland" off
    tearfree-amd "Xorg TearFree AMD" off
    tearfree-intel "Xorg TearFree Intel" off
    elan-trackpad "Fixes broken Elan trackpad on Lenovo Yoga Slim 7" off
    ms-fonts "Some microsoft fonts (the least broken package) (AUR)" off
    tlp "TLP" off
)
choicesTweaks=$("${cmdTweaks[@]}" "${optionsTweaks[@]}" 2>&1 >/dev/tty)
clear

for choice in ${choicesTweaks}; do
  case ${choice} in
  nm-wait-online)
    systemctl disable NetworkManager-wait-online.service
    ;;
  ax210-firmware)
    rm /lib/firmware/iwlwifi-ty-a0-gf-a0-6{6,7,8}.ucode.xz
    ;;
  xorg-libinput-accel)
    cat <<EOF >/etc/X11/xorg.conf.d/50-mouse-acceleration.conf
Section "InputClass"
	Identifier "My Mouse"
	Driver "libinput"
	MatchIsPointer "yes"
	Option "AccelProfile" "flat"
	Option "AccelSpeed" "0"
EndSection
EOF
    ;;
  mei_me)
    echo "blacklist mei_me" >>/etc/modprobe.d/blacklist.conf
    ;;
  ntfs)
    echo 'SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs3"' > /etc/udev/rules.d/ntfs3_by_default.rules
    ;;
  sddm-wayland)
    cat <<EOF >/etc/sddm.conf.d/10-sddm-wayland.conf
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --no-lockscreen --inputmethod maliit-keyboard
EOF
    ;;
  tearfree-amd)
    cat <<EOF >/etc/X11/xorg.conf.d/20-amdgpu.conf
Section "Device"
	Identifier "AMD GPU"
	Driver "amdgpu"
	Option "TearFree" "true"
EndSection
EOF
    ;;
  tearfree-intel)
    cat <<EOF >/etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
	Identifier "Intel GPU"
	Driver "intel"
	Option "TearFree" "true"
EndSection
EOF
    ;;
  elan-trackpad)
    # https://bbs.archlinux.org/viewtopic.php?id=266406
    echo "blacklist elan_i2c" >>/etc/modprobe.d/blacklist.conf
    # simillar bug report
    # https://gitlab.freedesktop.org/libinput/libinput/-/issues/694
    ;;
  ms-fonts)
    sudo -u "${username}" paru -S ttf-ms-fonts --noconfirm --needed
    ;;
  tlp)
    pacman -Rns power-profiles-daemon
    pacman -S tlp ethtool smartmontools tlp-rdw --noconfirm --needed
    sudo -u "${username}" paru -S tlpui --noconfirm --needed
    systemctl enable tlp.service
    systemctl enable NetworkManager-dispatcher.service
    systemctl mask systemd-rfkill.service
    systemctl mask systemd-rfkill.socket
    ;;
  esac
done
