#!/bin/bash

cmdFixes=(dialog --separate-output --checklist "Select the applications you want to install:" 0 0 0)
optionsFixes=(
  ax210-firmware "AX210 firmware fix" off
  xorg-libinput-accel "Disable Mouse acceleration (Xorg override)" on
  mei_me "Blacklist mei_me kernel module" off
  gnome-monitors "Configure my desktop monitors on gnome" off
  tearfree-amd "Xorg TearFree AMD" off
  tearfree-intel "Xorg TearFree Intel" off
  elan-trackpad "Fixes broken Elan trackpad on Lenovo Yoga Slim 7" off
)
choicesFixes=$("${cmdFixes[@]}" "${optionsFixes[@]}" 2>&1 >/dev/tty)
clear
