#!/bin/bash

for choice in ${choicesFixes}; do
  case ${choice} in
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
    sudo -u ${username} paru -S ttf-ms-fonts --noconfirm --needed
    ;;
  esac
done
