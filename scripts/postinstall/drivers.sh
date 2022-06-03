#!/bin/bash

for choice in ${choicesDrivers}; do
  case ${choice} in
  amd)
    # amd drivers
    pacman -S mesa mesa-utils vulkan-radeon vulkan-mesa-layers libva-mesa-driver mesa-vdpau vulkan-icd-loader --noconfirm --needed
    # multilib
    pacman -S lib32-mesa lib32-mesa-utils lib32-vulkan-radeon lib32-vulkan-mesa-layers lib32-libva-mesa-driver lib32-mesa-vdpau lib32-vulkan-icd-loader --noconfirm --needed
    # xorg amd driver
    pacman -S xf86-video-amdgpu --noconfirm --needed
    # additional
    pacman -S radeontop --noconfirm --needed
    ;;
  nvidia-proprietary)
    # i think explicitly installing mesa is still generally a good idea
    pacman -S mesa mesa-utils lib32-mesa lib32-mesa-utils --noconfirm --needed
    # nvidia drivers
    pacman -S nvidia nvidia-utils vulkan-icd-loader opencl-nvidia --noconfirm --needed
    # multilib
    pacman -S lib32-nvidia-utils lib32-opencl-nvidia lib32-vulkan-icd-loader --noconfirm --needed
    # additional
    pacman -S nvidia-settings nvtop --noconfirm --needed
    ;;
  intel-new)
    # intel drivers
    pacman -S mesa mesa-utils vulkan-intel vulkan-icd-loader vulkan-mesa-layers intel-media-driver --noconfirm --needed
    # xorg driver
    pacman -S xf86-video-intel --noconfirm --needed
    # multilib
    pacman -S lib32-mesa lib32-vulkan-intel lib32-vulkan-icd-loader lib32-vulkan-mesa-layers --noconfirm --needed
    pacman -S intel-gpu-tools --noconfirm --needed
    ;;
  intel-old)
    # intel drivers
    pacman -S mesa mesa-utils vulkan-intel vulkan-icd-loader vulkan-mesa-layers libva-intel-driver --noconfirm --needed
    # xorg driver
    pacman -S xf86-video-intel --noconfirm --needed
    # multilib
    pacman -S lib32-mesa lib32-vulkan-intel lib32-vulkan-icd-loader lib32-vulkan-mesa-layers --noconfirm --needed
    pacman -S intel-gpu-tools --noconfirm --needed
    ;;
  esac
done
