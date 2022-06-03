#!/bin/bash

cmdGaming=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsGaming=(
  wine "A compatibility layer for running Windows programs" on
  mangohud "An overlay layer for monitoring FPS and more" on
  gamemode "Allows games to request a set of optimisations be temporarily applied to the host OS" on
  steam "Valve's digital software store" on
  proton-ge "ProtonGE (AUR)" off
  steam-flatpak "Valve's digital software store (Flatpak)" off
  goverlay "An application to help manage MangoHud" off
  lutris "Open Gaming Platform" on
  lutris-flatpak "Open Gaming Platform (BETA Flatpak)" off
  gamescope "The micro-compositor" on
)
choicesGaming=$("${cmdGaming[@]}" "${optionsGaming[@]}" 2>&1 >/dev/tty)
