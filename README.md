<!-- markdownlint-disable-next-line no-inline-html -->
<h1 align="center">SILA</h1>

## Deprecation notice

The script is no longer maintained.
You should use [archinstall](https://github.com/archlinux/archinstall) instead.

## What is SILA?

SILA is a script that configures and installs a fully-featured Arch Linux system.

## Why is it named SILA?

Arch Linux Install Script (ALIS) spelled backwards.

## Features

- BTRFS filesystem.
- GRUB bootloader (works with both UEFI and BIOS systems).
- Optional: Full disk LUKS encryption.
- Pipewire and Wireplumber.
- GNOME or KDE desktops (nothing is an option as well).
- Optional: User configuration installation. See the section [below](#user-configuration-installation).
- Many different applications to choose from, both generic and gaming related.
- Virtualization with QEMU/KVM.
- Podman or Docker.

## Limitations

- Dual Boot
- No secure boot.
- Only a limited number of locales are generated at install time.

## Step-by-step instructions

1. Boot the Arch Linux iso. You can use [Ventoy](https://www.ventoy.net/en/index.html) for that.
1. Run the script using the command below.
1. Follow the instructions given by the installer.
1. Reboot your computer.
   - **You will have to log in as root after the reboot.**
1. The script will launch automatically.
   - You can always launch it manually with `bash /root/sila/scripts/postinstall.sh`.
1. Follow the installer instructions. Read each page carefully and select what you want to install.
1. Reboot your computer again.
1. ?
1. Profit

## How to run the script?

```bash
# with a helper script:
# IMPORTANT: it is strongly advised to check the source code of the script before running it
curl -L sila.sgf.lt | bash

# or manually:
pacman -Sy git
git clone https://github.com/richard96292/sila /tmp/sila
bash /tmp/sila/scripts/1-archinstall.sh
```

## In case something fails

You can always cancel the script with `Ctrl-C` when it is running.
Then you can either run `exit` and log in as root again or start the postinstall script manually.
If you run the script a second time just select the same options. It _should_ work fine.

Most likely, some package names have changed.
I can't do anything about that.
In the case of the postinstall the repo is cloned to `/root/sila`.
You need to find the package and remove it from a script.
After that, be sure to submit a pull request with your fixes.

## Advanced features

### Dual boot

Having two systems on the _same_ drive is not supported at all.
And Windows on the _second_ drive will not be detected automatically.
Follow this [tutorial](https://forum.endeavouros.com/t/tutorial-add-a-systemd-boot-loader-menu-entry-for-a-windows-installation-using-a-separate-esp-partition/37431)
if you want Windows to show up in the systemd-boot menu.

### User configuration installation

SILA optionally supports running the dotfile installation script given by the user.
As the last step in the installation process, the user can install the dotfiles from a personal git repository.
You will need to enter your dotfile repo URL link.
The git repository has to be public for the script to access it.
The default value is `https://github.com/richard96292/dotfiles`.
The script will search for a sila-install-script.sh in the root directory of the cloned repo and execute it.
You can find an example of such a script in [my dotfiles repo](https://github.com/richard96292/dotfiles).

## Screenshots

![Tutorial](https://github.com/richard96292/sila/blob/master/images/tutorial.png)
![Disk encryption](https://github.com/richard96292/sila/blob/master/images/encryption.png)
![Installing applications](https://github.com/richard96292/sila/blob/master/images/applications.png)
