<h1 align="center">ALIS - SILA</h1>

## What is ALIS?

Arch Linux Install Script (ALIS) is a script that configures and installs a fully-featured Arch Linux system.

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

- Dual boot on the same drive is not supported.
- No secure boot.
- Only a limited number of locales is generated at install time.

## How to run the script?

```bash
# with a helper script:
# IMPORTANT: it is strongly advised to check the source code of the script before running it blindly
curl -L alis.segf.lt | bash

# or manually:
pacman -Sy git
git clone https://github.com/richard96292/alis /tmp/alis
bash /tmp/alis/scripts/1-archinstall.sh
```

## Step-by-step instructions:

1. Boot the Arch Linux iso. You can use [Ventoy](https://www.ventoy.net/en/index.html) for that.
1. Run the script using the command above.
1. Follow the instructions given by the installer.
1. Reboot your computer.
   - **You will have to log in as root after the reboot.**
1. The script will launch automatically.
   - You can always launch it manually with `bash /root/alis/scripts/postinstall.sh`.
1. Follow the installer instructions. Read each page carefully and select what you want to install.
1. Reboot your computer again.
1. ?
1. Profit

## Advanced features

### User configuration installation

ALIS optionally supports running the dotfile installation script given by the user.
As the last step in the installation process, the user can install the dotfiles from a personal git repository.
You will need to enter your dotfile repo URL link.
The git repository has to be public for the script to access it.
The default value is `https://github.com/richard96292/dotfiles`.
The script will search for an alis-install-script.sh in the root directory of the cloned repo and execute it.
You can find an example of such a script in [my dotfiles repo](https://github.com/richard96292/dotfiles).

## Screenshots

![Tutorial](https://github.com/richard96292/alis/blob/master/images/tutorial.png)
![Disk encryption](https://github.com/richard96292/alis/blob/master/images/encryption.png)
![Installing applications](https://github.com/richard96292/alis/blob/master/images/applications.png)
