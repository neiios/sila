#!/bin/bash

function cloneRepo() {
  while true; do
    link=$(dialog --erase-on-exit --title "Git repo link" --nocancel --inputbox "Enter the repository url:\nYou probably want to change the default url." 0 0 "https://github.com/richard96292/dotfiles" 3>&1 1>&2 2>&3)

    [[ -d "/tmp/dotfiles" ]] && rm -rf "/tmp/dotfiles"
    cd /tmp || error "Tmp dir does not exist."
    if git clone "${link}" "/tmp/dotfiles"; then
      [[ -d "/home/${username:?Username not set.}/.dotfiles" ]] && rm -rf "/home/${username}/.dotfiles"
      mv "/tmp/dotfiles" "/home/${username}/.dotfiles"
      chown -R "${username}:${username}" "/home/${username}/.dotfiles"
      return
    else
      dialog --erase-on-exit --title "Error" --yes-button "Continue" --no-button "Cancel" --yesno "The git repository doesn't exist. Verify the link and enter it again.\n\n" 0 0 || return
    fi
  done
}

function installDotfiles() {
  while true; do
    cloneRepo
    cd "/home/${username}/.dotfiles" || error "Dotfiles dir does not exist."

    if [[ -e sila-install-dotfiles.sh ]]; then
      # just like with gnome configuration need to be careful about the dbus session and systemd for a user
      sudo su -l "${username}" "dbus-run-session -- bash sila-install-dotfiles.sh"
      return
    else
      dialog --erase-on-exit --title "Error" --yesno "The sila-install-dotfiles.sh script can't be found.\n\nCancel dotfile installation?" 0 0 && return
    fi
  done
}

if (dialog --erase-on-exit --title "Dotfiles" --defaultno --yesno "You can optionally install your dotfiles from a git repository.\nYou will need to enter the dotfile repository link.\nThe script needs sila-install-dotfiles.sh file in the root of the repository.\nDo you want to install the dotfiles?" 0 0); then
  installDotfiles
fi
