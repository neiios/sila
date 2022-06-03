#!/bin/bash

cmdDrivers=(dialog --separate-output --checklist "Select you videocard:" 0 0 0)
optionsDrivers=(
  amd "AMD" on
  nvidia-proprietary "Nvidia (proprietary)" off
  intel-new "Intel (from Broadwell)" off
  intel-old "Intel (older CPUs)" off
)
choicesDrivers=$("${cmdDrivers[@]}" "${optionsDrivers[@]}" 2>&1 >/dev/tty)
clear
