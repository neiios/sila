#!/bin/bash

# drivers input
cmdDrivers=(dialog --erase-on-exit --title "Drivers" --checklist "Select the drivers you want to use:" 0 0 0)
optionsDrivers=(
  amd "AMD" on
  nvidia-proprietary "Nvidia (proprietary)" off
  intel-new "Intel (from Broadwell)" off
  intel-old "Intel (older CPUs)" off
)
choicesDrivers=$("${cmdDrivers[@]}" "${optionsDrivers[@]}" 2>&1 >/dev/tty)

for choice in ${choicesDrivers}; do
  case ${choice} in
    amd)
      # amd drivers
      pacman -S mesa mesa-utils vulkan-radeon vulkan-mesa-layers libva-mesa-driver mesa-vdpau vulkan-icd-loader --noconfirm --needed
      # opencl
      pacman -S opencl-mesa ocl-icd --noconfirm --needed
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
      # opencl
      pacman -S intel-compute-runtime libdrm libva --noconfirm --needed
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
