#!/usr/bin/env bash
# generated with:
# gsettings list-recursively > /tmp/gsettings.before
# gsettings list-recursively > /tmp/gsettings.after
# diff /tmp/gsettings.before /tmp/gsettings.after | sed 's/>/gsettings set/;tx;d;:x' > gnome-configure.sh
set -xe

# favorite applications
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'chromium.desktop', 'thunderbird.desktop', 'telegramdesktop.desktop', 'com.discordapp.Discord.desktop', 'discord.desktop', 'com.spotify.Client.desktop', 'com.valvesoftware.Steam.desktop', 'steam.desktop', 'net.lutris.Lutris.desktop', 'bitwarden.desktop', 'org.keepassxc.KeePassXC.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'code-oss.desktop']"

# application folders
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.app-folders folder-children "['space-wasters', 'tools']"

sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/space-wasters/ name 'Space Wasters'
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/space-wasters/ apps "['yelp.desktop', 'cmake-gui.desktop', 'hplip.desktop', 'libreoffice-startcenter.desktop', 'libreoffice-math.desktop', 'libreoffice-base.desktop', 'libreoffice-draw.desktop', 'lstopo.desktop', 'electron14.desktop', 'hp-uiscan.desktop', 'electron13.desktop', 'avahi-discover.desktop', 'bvnc.desktop', 'bssh.desktop', 'nm-connection-editor.desktop', 'org.gnome.Epiphany.desktop', 'qvidcap.desktop', 'qv4l2.desktop', 'qdbusviewer.desktop', 'linguist.desktop', 'designer.desktop', 'assistant.desktop']"

sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/tools/ name 'Tools'
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/tools/ apps "['winetricks.desktop', 'nvidia-settings.desktop', 'timeshift-gtk.desktop', 'vim.desktop', 'ca.desrt.dconf-editor.desktop', 'tlpui.desktop']"

# gedit
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.gedit.preferences.editor bracket-matching false
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.gedit.preferences.editor highlight-current-line false

# file chooser
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gtk.Settings.FileChooser show-hidden true
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gtk.Settings.FileChooser sort-directories-first true

# mutter
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.mutter center-new-windows true
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.mutter attach-modal-dialogs false

# cleaning
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.privacy recent-files-max-age 30
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.privacy remove-old-temp-files true
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.privacy remove-old-trash-files true

# theme
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'

# clock
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface clock-show-seconds true
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface clock-show-date false

# mouse
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

# layouts
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'lt'), ('xkb', 'ru')]"

# idle delay
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.session idle-delay 1200

# buttons
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,close"

# disable fucking bell
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.wm.preferences audible-bell false
# and event sounds
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.sound event-sounds false

# terminal always dark
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'

# dont notify
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.tweaks show-extensions-notice false

# nautilus
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.nautilus.preferences show-create-link true
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.nautilus.preferences show-delete-permanently true
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.nautilus.icon-view captions "['size', 'none', 'none']"
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.nautilus.icon-view default-zoom-level "small"

# sys monitor
sudo -u ${username} dbus-launch --exit-with-session gsettings set org.gnome.gnome-system-monitor show-dependencies true

# add basic templates
mkdir -p /home/${username}/Templates
touch /home/${username}/Templates/New\ Document.txt

# wallpaper
# sudo cp /root/ALIS/configs/my-default-wallpaper.jpg /usr/share/backgrounds/my-default-wallpaper.jpg
# gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/my-default-wallpaper.jpg'

# https://bbs.archlinux.org/viewtopic.php?id=194902
# disable mouse acceleration for GDM
echo "[org.gnome.desktop.peripherals.mouse]" | sudo tee /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
echo "accel-profile='flat'" | sudo tee -a /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
