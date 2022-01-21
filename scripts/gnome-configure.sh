#!/usr/bin/env bash
# generated with:
# gsettings list-recursively > /tmp/gsettings.before
# gsettings list-recursively > /tmp/gsettings.after
# diff /tmp/gsettings.before /tmp/gsettings.after | sed 's/>/gsettings set/;tx;d;:x' > gnome-configure.sh

# Todo set default wallpaper

gsettings set org.gnome.gedit.preferences.editor bracket-matching false
gsettings set org.gnome.gedit.preferences.editor highlight-current-line false

gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.telegram.desktop.desktop', 'org.gnome.Music.desktop', 'org.keepassxc.KeePassXC.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'code-oss.desktop', 'jetbrains-clion.desktop']"
gsettings set org.gnome.shell app-picker-layout "[{'org.gnome.clocks.desktop': <{'position': <0>}>, 'org.gnome.Books.desktop': <{'position': <1>}>, 'org.gnome.Photos.desktop': <{'position': <2>}>, 'org.gnome.Totem.desktop': <{'position': <3>}>, 'com.discordapp.Discord.desktop': <{'position': <4>}>, 'org.gnome.gedit.desktop': <{'position': <5>}>, 'gnome-control-center.desktop': <{'position': <6>}>, 'gnome-system-monitor.desktop': <{'position': <7>}>, 'org.gnome.FileRoller.desktop': <{'position': <8>}>, 'org.gnome.font-viewer.desktop': <{'position': <9>}>, 'org.gnome.Calendar.desktop': <{'position': <10>}>, 'virt-manager.desktop': <{'position': <11>}>, 'steam.desktop': <{'position': <12>}>, 'thunderbird.desktop': <{'position': <13>}>, 'org.qbittorrent.qBittorrent.desktop': <{'position': <14>}>, 'org.gnome.tweaks.desktop': <{'position': <15>}>, 'org.kde.kdenlive.desktop': <{'position': <16>}>, 'com.obsproject.Studio.desktop': <{'position': <17>}>, 'com.github.wwmm.easyeffects.desktop': <{'position': <18>}>, 'timeshift-gtk.desktop': <{'position': <19>}>, 'io.github.shiftey.Desktop.desktop': <{'position': <20>}>, 'gimp.desktop': <{'position': <21>}>, 'org.gnome.Software.desktop': <{'position': <22>}>}, {'org.gnome.Extensions.desktop': <{'position': <0>}>, 'io.github.benjamimgois.goverlay.desktop': <{'position': <1>}>, 'org.gnome.Connections.desktop': <{'position': <2>}>, 'vim.desktop': <{'position': <3>}>, 'org.gnome.Epiphany.desktop': <{'position': <4>}>, 'winetricks.desktop': <{'position': <5>}>, 'Utilities': <{'position': <6>}>, 'simple-scan.desktop': <{'position': <7>}>, 'org.gnome.Calculator.desktop': <{'position': <8>}>, 'org.gnome.Weather.desktop': <{'position': <9>}>, 'org.gnome.Maps.desktop': <{'position': <10>}>, 'org.gnome.Contacts.desktop': <{'position': <11>}>, 'org.gnome.Cheese.desktop': <{'position': <12>}>}]"

gsettings set org.gnome.system.locale region 'lt_LT.UTF-8'

gsettings set org.gtk.Settings.FileChooser show-hidden true
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

# these 2 dont work
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.mutter attach-modal-dialogs false

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'

gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver primary-color '#000000000000'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000000000'
gsettings set org.gnome.desktop.privacy recent-files-max-age 30
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.privacy remove-old-trash-files true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-date false
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'lt'), ('xkb', 'ru')]"
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,close"
gsettings set org.gnome.desktop.wm.preferences audible-bell false

gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'

gsettings set org.gnome.tweaks show-extensions-notice false

gsettings set org.gnome.nautilus.preferences show-create-link true
gsettings set org.gnome.nautilus.preferences show-delete-permanently true

gsettings set com.github.wwmm.easyeffects.streamoutputs plugins "['equalizer']"
gsettings set com.github.wwmm.easyeffects window-maximized true
gsettings set com.github.wwmm.easyeffects use-dark-theme true

gsettings set org.gnome.gnome-system-monitor show-dependencies true

gsettings set org.gnome.nautilus.icon-view captions "['size', 'none', 'none']"
gsettings set org.gnome.nautilus.icon-view default-zoom-level "small"

sudo cp ~/script/configs/my-default-wallpaper.jpg /usr/share/backgrounds/my-default-wallpaper.jpg
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/my-default-wallpaper.jpg'

# https://bbs.archlinux.org/viewtopic.php?id=194902
echo "[org.gnome.desktop.peripherals.mouse]" | sudo tee /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
echo "accel-profile='flat'" | sudo tee -a /usr/share/glib-2.0/schemas/69_acceleration.gschema.override
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
