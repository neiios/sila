#!/bin/bash

for choice in ${choicesFixes}; do
  case ${choice} in
  ax210)
    rm /lib/firmware/iwlwifi-ty-a0-gf-a0-6{6,7,8}.ucode.xz
    ;;
  accel)
    cat <<EOF >/etc/X11/xorg.conf.d/50-mouse-acceleration.conf
Section "InputClass"
	Identifier "My Mouse"
	Driver "libinput"
	MatchIsPointer "yes"
	Option "AccelProfile" "flat"
	Option "AccelSpeed" "0"
EndSection
EOF
    ;;
  mei_me)
    echo "blacklist mei_me" >>/etc/modprobe.d/blacklist.conf
    ;;
  esac
done
