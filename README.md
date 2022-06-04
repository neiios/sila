# Arch Linux Install Script

## What is Arch Linux Install Script?

ALIS is a script that configures and installs a fully-featured Arch Linux system.

The ALIS consists of two stages:

- Stage 1 installs a minimal Arch Linux system.
- Stage 2 configures the user, installs various DEs and user applications.

## Stage 1

- **Stage 1 DOES NOT create any additional users (only the root user will be available after reboot).**
- **To log in after reboot use "root" as the username and the password you set.**

```bash
curl alis.neiio.xyz | bash
```

## Stage 2

- **The script should be run as root.**

```bash
bash post-archinstall.sh
```

## Screenshots

![Disk selection](https://github.com/richard96292/ALIS/blob/master/screenshots/disk.png)
![Hostname selection](https://github.com/richard96292/ALIS/blob/master/screenshots/hostname.png)

## TODO

- [ ] Divide gnome configuration
- [ ] Split applications
- [ ] Run postinstall before reboot
