#!/bin/bash

cmdFixes=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsFixes=(
  ax210-firmware "AX210 firmware fix" off
  xorg-libinput-accel "Disable Mouse acceleration (Xorg override)" on
  mei_me "Blacklist mei_me kernel module" off
  gnome-monitors "Configure my desktop monitors on gnome" off
)
choicesFixes=$("${cmdFixes[@]}" "${optionsFixes[@]}" 2>&1 >/dev/tty)
clear
