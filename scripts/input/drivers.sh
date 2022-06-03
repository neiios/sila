#!/bin/bash

cmdDrivers=(dialog --separate-output --checklist "Select you videocard:" 0 0 0)
optionsDrivers=(
  1 "AMD" on
  2 "Nvidia" off
  3 "Intel" off
  4 "Enable TearFree (for AMD on Xorg)" off
  5 "Enable TearFree (for Intel on Xorg)" off
  6 "Nvidia graphics card on a laptop (envycontrol + nvidia-prime) EXPERIMENTAL" off
)
choicesDrivers=$("${cmdDrivers[@]}" "${optionsDrivers[@]}" 2>&1 >/dev/tty)
clear
