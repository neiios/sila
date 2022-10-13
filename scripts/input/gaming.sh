#!/bin/bash

cmdGaming=(whiptail --separate-output --checklist "Select applications to install:" 0 0 0)
optionsGaming=(
  wine "A compatibility layer for running Windows programs" on
  mangohud "An overlay layer for monitoring FPS and more" off
  gamemode "Allows games to request a set of optimisations be temporarily applied to the host OS" off
  steam "Valve's digital software store" off
  steam-flatpak "Valve's digital software store (Flatpak)" off
  proton-ge "ProtonGE (AUR)" off
  gamescope "The micro-compositor" off
  goverlay "An application to help manage MangoHud" off
  lutris "Open Gaming Platform" off
  lutris-flatpak "Open Gaming Platform (Flatpak)" off
)
choicesGaming=$("${cmdGaming[@]}" "${optionsGaming[@]}" 2>&1 >/dev/tty)
