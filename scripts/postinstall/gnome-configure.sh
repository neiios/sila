#!/bin/bash

# generated with:
# gsettings list-recursively > /tmp/gsettings.before
# gsettings list-recursively > /tmp/gsettings.after
# diff /tmp/gsettings.before /tmp/gsettings.after | sed 's/>/gsettings set/;tx;d;:x' > gnome-configure.sh

echo "Changing gnome configuration with gsettings."
sleep 2

# trash
gsettings set org.gnome.desktop.privacy recent-files-max-age 30
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.privacy remove-old-trash-files true
# theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# clock
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-date false
# mouse
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
# layouts
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'lt'), ('xkb', 'ru')]"
# and event sounds
gsettings set org.gnome.desktop.sound event-sounds false
# set fonts
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
# dont notify
gsettings set org.gnome.tweaks show-extensions-notice false
# sys monitor
gsettings set org.gnome.gnome-system-monitor show-dependencies true
# make timeout larger
gsettings set org.gnome.mutter check-alive-timeout 60000

# https://bbs.archlinux.org/viewtopic.php?id=194902
# disable mouse acceleration for GDM
echo "[org.gnome.desktop.peripherals.mouse]" | sudo tee /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
echo "accel-profile='flat'" | sudo tee -a /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
