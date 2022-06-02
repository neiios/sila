#!/bin/bash

for choice in ${choicesFixes}; do
  case ${choice} in
  ax210-firmware)
    rm /lib/firmware/iwlwifi-ty-a0-gf-a0-6{6,7,8}.ucode.xz
    ;;
  xorg-libinput-accel)
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
  gnome-monitors)
    curl --create-dirs --output /home/${username}/.config/monitors.xml https://raw.githubusercontent.com/richard96292/ALIS/master/configs/monitors.xml
    sudo -u gdm curl --create-dirs --output /var/lib/gdm/.config/monitors.xml https://raw.githubusercontent.com/richard96292/ALIS/master/configs/monitors.xml
    ;;
  esac
done
