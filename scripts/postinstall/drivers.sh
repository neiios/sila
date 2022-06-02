#!/bin/bash

for choice in ${choicesDrivers}; do
  case ${choice} in
  1)
    # amd drivers
    pacman -S mesa mesa-utils vulkan-radeon vulkan-mesa-layers libva-mesa-driver mesa-vdpau vulkan-icd-loader --noconfirm --needed
    # multilib
    pacman -S lib32-mesa lib32-mesa-utils lib32-vulkan-radeon lib32-vulkan-mesa-layers lib32-libva-mesa-driver lib32-mesa-vdpau lib32-vulkan-icd-loader --noconfirm --needed
    # xorg amd driver
    pacman -S xf86-video-amdgpu --noconfirm --needed
    # additional
    pacman -S radeontop --noconfirm --needed
    ;;
  2)
    # i think explicitly installing mesa is still generally a good idea
    pacman -S mesa mesa-utils lib32-mesa lib32-mesa-utils --noconfirm --needed
    # nvidia drivers
    pacman -S nvidia nvidia-utils vulkan-icd-loader opencl-nvidia --noconfirm --needed
    # multilib
    pacman -S lib32-nvidia-utils lib32-opencl-nvidia lib32-vulkan-icd-loader --noconfirm --needed
    # additional
    pacman -S nvidia-settings nvtop --noconfirm --needed
    ;;
  3)
    # intel drivers
    pacman -S mesa mesa-utils vulkan-intel vulkan-icd-loader vulkan-mesa-layers intel-media-driver libva-intel-driver --noconfirm --needed
    # xorg driver
    pacman -S xf86-video-intel --noconfirm --needed
    # multilib
    pacman -S lib32-mesa lib32-vulkan-intel lib32-vulkan-icd-loader lib32-vulkan-mesa-layers --noconfirm --needed
    ;;
  4)
    cat <<EOF >/etc/X11/xorg.conf.d/20-amdgpu.conf
Section "Device"
	Identifier "AMD GPU"
	Driver "amdgpu"
	Option "TearFree" "true"
EndSection
EOF
    ;;
  5)
    cat <<EOF >/etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
	Identifier "Intel GPU"
	Driver "intel"
	Option "TearFree" "true"
EndSection
EOF
    ;;
  6)
    pacman -S nvidia-prime --noconfirm --needed
    paru -S envycontrol --noconfirm --needed
    ;;
  esac
done
