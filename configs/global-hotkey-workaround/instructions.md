# **Definitive guide to global hotkeys and push to talk on Wayland...**

### ...if your target app runs on Xorg

### **NOTE: Use two different keys (in the app and for executing a script)**

## **I want to use a global hotkey:**

1. Install xdotool

2. Set up a custom hotkey **you want to actually use** in your DE settings to execute the 'global-hotkey.sh' script

   - sh path-to/global-hotkey.sh
     - Don't forget to change the hotkey inside 'global-hotkey.sh'
     - If you use GNOME you may need to modify a dconf entry (depending on the hotkey you want to use, not all keys can be set from a GUI)

3. Add the hotkey from 'global-hotkey.sh' to the application you want to use (Mumble, Teamspeak, or Discord for example)

## **I want to use push to talk:**

The workaround is from this post: https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/2838

1. Install python 3, pip and xdotool
2. Install asyncudp with: pip3 install asyncudp

   - it may be called just pip

3. Set up a custom hotkey **you want to actually use for push to talk** in your DE settings to execute the 'push-to-talk-hotkey.sh' script

   - sh path-to/push-to-talk-hotkey.sh
   - If you use GNOME you may need to modify a dconf entry (depending on the hotkey you want to use, not all keys can be set from a GUI)

4. If you are using GNOME, copy 'push-to-talk-hotkey.desktop' to home/your_username/.config/autostart

   - You can place 'push-to-talk-hotkey.py' anywhere in your home folder
   - Don't forget to change the path to 'push-to-talk-hotkey.py' inside .desktop file

5. If you are using KDE, you can add the 'push-to-talk-hotkey.py' file to autostart through GUI settings

   - You can place 'push-to-talk-hotkey.py' anywhere in your home folder
   - python3 path-to/push-to-talk-hotkey.py

6. Add the hotkey from 'push-to-talk-hotkey.py' to the application you want to use (Mumble, Teamspeak, or Discord for example)

7. Reboot your computer

8. The python script should automatically start and you should be able to use your push to talk hotkey even in windows running on Wayland!

# **GNOME does not allow me to use the hotkey I want:**

1. Run 'dconf watch /' in the terminal

2. Modify the hotkey in the settings

3. Path to the setting will be in the terminal

4. Open dconf editor, navigate to the hotkey and change it

   - You will have no artificial limitations and will be able to set any key
