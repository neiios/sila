<h1 align="center">ALIS - SILA</h1>

## What is ALIS?

Arch Linux Install Script (ALIS) is a script that configures and installs a fully-featured Arch Linux system.

## How to run the script?

```bash
# with a helper script:
# it is strongly advised to check the source code of the script before running it
curl -L alis.segf.lt | bash

# or manually:
pacman -Sy git
git clone https://github.com/richard96292/alis /tmp/alis
bash /tmp/alis/scripts/1-archinstall.sh
```

### Step-by-step instructions:

1. Boot the Arch Linux iso. You can use [Ventoy](https://www.ventoy.net/en/index.html) for that.
1. Run the script using the command above.
1. Follow the instructions given by the installer.
1. Reboot your computer.
   - **You will have to log in as root after the reboot.**
1. Follow the installer instructions. Read each page carefully and select what you want to install.
1. Reboot your computer again.
1. ?
1. Profit

## Screenshots

![Tutorial](https://github.com/richard96292/alis/blob/master/screenshots/tutorial.png)
![Disk encryption](https://github.com/richard96292/alis/blob/master/screenshots/encryption.png)
