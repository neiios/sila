#!/bin/bash

function cloneRepo() {
  while true; do
    link=$(whiptail --title "Git repo link" --nocancel --inputbox "Enter the repository url:\nYou probably want to change the default url." 0 0 "http://github.com/richard96292/dotfiles" 3>&1 1>&2 2>&3)

    [[ -d "/tmp/dotfiles" ]] && sudo rm -rf "/tmp/dotfiles"
    if git clone "${link}" "/tmp/dotfiles"; then
      [[ -d "/home/${username:?Username is not set.}/.dotfiles" ]] && sudo rm -rf "/home/${username}/.dotfiles"
      mv "/tmp/dotfiles" "/home/${username}/.dotfiles"
      return
    else
      whiptail --title "Error" --yes-button "Continue" --no-button "Cancel" --yesno "The git repository doesn't exist. Verify the link and enter it again.\n\n" 0 0 || return
    fi
  done
}

function installDotfiles() {
  while true; do
    sudo -u "${username:?Username is not set.}" cloneRepo
    cd "/home/${username}/.dotfiles" || error "Dotfile dir does not exist."

    if [[ -e alis-install-dotfiles.sh ]]; then
      sudo -u "${username}" bash alis-install-dotfiles.sh
      return
    else
      whiptail --title "Error" --yesno "The alis-install-dotfiles.sh script can't be found.\n\nCancel dotfile installation?" 0 0 && return
    fi
  done
}

if (whiptail --title "Dotfiles" --yesno "You can optionally install your dotfiles from a git repository.\n\nYou will need to enter the dotfile repository link.\n\nThe script needs alis-install-dotfiles.sh file in the root of the repository.\n\nDo you want to install the dotfiles?" 0 0); then
  installDotfiles
fi
