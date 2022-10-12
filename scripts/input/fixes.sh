#!/bin/bash

cmdFixes=(whiptail --separate-output --checklist "Select some fixes/workarounds you want to apply:" 0 0 0)
optionsFixes=(
  ax210-firmware "AX210 firmware fix" off
  xorg-libinput-accel "Disable Mouse acceleration (Xorg override)" on
  mei_me "Blacklist mei_me kernel module" off
  gnome-monitors "Configure my desktop monitors on gnome" off
  tearfree-amd "Xorg TearFree AMD" off
  tearfree-intel "Xorg TearFree Intel" off
  elan-trackpad "Fixes broken Elan trackpad on Lenovo Yoga Slim 7" off
  ms-fonts "Some microsoft fonts (the least broken package) (AUR)" off
)
choicesFixes=$("${cmdFixes[@]}" "${optionsFixes[@]}" 2>&1 >/dev/tty)
