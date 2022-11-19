#!/bin/bash

set +e

# generated with:
# gsettings list-recursively > /tmp/gsettings.before
# gsettings list-recursively > /tmp/gsettings.after
# diff /tmp/gsettings.before /tmp/gsettings.after | sed 's/>/gsettings set/;tx;d;:x' > gnome-configure.sh

# cleaning
sudo -u "${username:?Username not set.}" dbus-launch --exit-with-session gsettings set org.gnome.desktop.privacy recent-files-max-age 30
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.privacy remove-old-temp-files true
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.privacy remove-old-trash-files true
# theme
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# clock
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface clock-show-seconds true
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface clock-show-date false
# mouse
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
# layouts
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'lt'), ('xkb', 'ru')]"
# and event sounds
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.sound event-sounds false
# set fonts
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
# terminal always dark
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
# dont notify
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.tweaks show-extensions-notice false
# sys monitor
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.gnome-system-monitor show-dependencies true
# make timeout larger
sudo -u "$username" dbus-launch --exit-with-session gsettings set org.gnome.mutter check-alive-timeout 60000

# https://bbs.archlinux.org/viewtopic.php?id=194902
# disable mouse acceleration for GDM
echo "[org.gnome.desktop.peripherals.mouse]" | sudo tee /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
echo "accel-profile='flat'" | sudo tee -a /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
sudo glib-compile-schemas /usr/share/glib-2.0/schemas

set -e

# hide desktop entries
# echo "[Desktop Entry]
# Hidden=true" > /tmp/1

# find /usr -name "*lsp_plug*desktop" 2>/dev/null | cut -f 5 -d '/' | xargs -I {} cp /tmp/1 ~/.local/share/applications/{}
