# Arch Linux Install Script

## What is Arch Linux Install Script?

ALIS is a script that configures and installs a fully-featured Arch Linux system.

The ALIS consists of two stages:

- Stage 1 installs a minimal Arch Linux system.
- Stage 2 configures the user, installs various DEs and user applications.

It is not necessary to run Stage 1 before executing Stage 2, but it is heavily recommended.

## Stage 1:

- **Stage 1 DOES NOT create any additional users (only the root user will be available after reboot).**
- **To log in after reboot use "root" as the username and the password you set.**

```bash
curl https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/1-archinstall.sh | bash
```

## Stage 2:

- **The script should be run as root.**
- **If you are running an Nvidia graphics card, you are better off selecting Xorg session in your display manager.**

### On a system installed using stage 1, run the following:

```bash
bash post-archinstall.sh
```

### If you installed the system manually, run the following:

```bash
curl https://raw.githubusercontent.com/richard96292/ALIS/master/scripts/post-archinstall.sh | bash
```

## TODO

- [x] Make it possible to run scripts without cloning the repository
- [x] Nvidia drivers (Needs testing)
- [x] Intel drivers (Needs testing)
- [x] GNOME desktop
- [ ] Make everything a function
- [x] Pre apply sddm config when installing Plasma
- [ ] Add ninja, meson
