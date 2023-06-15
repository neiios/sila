#!/bin/bash

# drivers input
cmdDrivers=(dialog --erase-on-exit --title "GPU Drivers" --menu "Select the GPU drivers you want to use:" 0 0 0)
optionsDrivers=(
  amd "AMD"
  nvidia-proprietary "Nvidia (proprietary)"
  intel-new "Intel (from Broadwell)"
  intel-old "Intel (older CPUs)"
)
choicesDrivers=$("${cmdDrivers[@]}" "${optionsDrivers[@]}" 2>&1 >/dev/tty)

for choice in ${choicesDrivers}; do
  case ${choice} in
    amd)
      pacman -S mesa mesa-utils vulkan-radeon vulkan-mesa-layers libva-mesa-driver mesa-vdpau vulkan-icd-loader --noconfirm --needed
      pacman -S opencl-mesa ocl-icd --noconfirm --needed
      pacman -S lib32-mesa lib32-mesa-utils lib32-vulkan-radeon lib32-vulkan-mesa-layers lib32-libva-mesa-driver lib32-mesa-vdpau lib32-vulkan-icd-loader --noconfirm --needed
      pacman -S radeontop --noconfirm --needed
      ;;
    nvidia-proprietary)
      pacman -S mesa mesa-utils lib32-mesa lib32-mesa-utils --noconfirm --needed
      pacman -S nvidia nvidia-utils vulkan-icd-loader opencl-nvidia --noconfirm --needed
      pacman -S lib32-nvidia-utils lib32-opencl-nvidia lib32-vulkan-icd-loader --noconfirm --needed
      pacman -S nvidia-settings nvtop --noconfirm --needed
      ;;
    intel-new)
      pacman -S mesa mesa-utils vulkan-intel vulkan-icd-loader vulkan-mesa-layers intel-media-driver --noconfirm --needed
      pacman -S intel-compute-runtime libdrm libva --noconfirm --needed
      pacman -S lib32-mesa lib32-vulkan-intel lib32-vulkan-icd-loader lib32-vulkan-mesa-layers --noconfirm --needed
      pacman -S intel-gpu-tools --noconfirm --needed
      ;;
    intel-old)
      pacman -S mesa mesa-utils vulkan-intel vulkan-icd-loader vulkan-mesa-layers libva-intel-driver --noconfirm --needed
      pacman -S lib32-mesa lib32-vulkan-intel lib32-vulkan-icd-loader lib32-vulkan-mesa-layers --noconfirm --needed
      pacman -S intel-gpu-tools --noconfirm --needed
      ;;
  esac
done
