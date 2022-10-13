#!/bin/bash

function usernameInput() {
    while true; do
        u=$(whiptail --title "Username" --inputbox "${invalidMessage}Enter the username:" 0 0 3>&1 1>&2 2>&3)
        [[ "${u}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]] && echo "${u}" && break
        invalidMessage="The username is invalid.\nValid username should contain up to 32 lowercase letters, number, underscores and hyphens.\nThe username may end with a \$.\n"
    done
}

username=$(usernameInput)

function inputPass() {
    while true; do
        t=$(whiptail --title "$1 password" --passwordbox "${invalidPasswordMessage}Enter the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        t2=$(whiptail --title "$1 password" --passwordbox "Retype the $1 password:" --nocancel 10 50 3>&1 1>&2 2>&3)
        [[ "${t}" == "${t2}" ]] && [[ -n "${t}" ]] && [[ -n "${t2}" ]] && echo "${t}" && break
        # special case for disk encryption (it can be an empty string)
        [[ "${t}" == "${t2}" ]] && [[ "$1" == "Disk encryption" ]] && echo "${t}" && break
        invalidPasswordMessage="The passwords did not match or you have entered an empty string.\n\n"
    done
}

password="$(inputPass "Regular user")"

# drivers input
curl --create-dirs --output /tmp/input-drivers.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/drivers.sh && source /tmp/input-drivers.sh

# desktop input
curl --create-dirs --output /tmp/input-desktop.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/desktop.sh && source /tmp/input-desktop.sh

# software input
curl --create-dirs --output /tmp/input-software.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/software.sh && source /tmp/input-software.sh

# gaming input
curl --create-dirs --output /tmp/input-gaming.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/gaming.sh && source /tmp/input-gaming.sh

# fixes input
curl --create-dirs --output /tmp/input-fixes.sh https://raw.githubusercontent.com/richard96292/alis/master/scripts/input/fixes.sh && source /tmp/input-fixes.sh
