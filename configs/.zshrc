#!/bin/zsh

## autoload vcs and colors
setopt nomatch menucomplete
stty stop undef # disable ctrl-s to freeze terminal
autoload -U colors && colors
zle_highlight=('paste:none') # remove highlighting on paste

unsetopt BEEP # removes beeping

# History in cache directory:
HISTFILE=~/.cache/zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Basic auto/tab complete:
autoload -U compinit
compinit

# modes v for vi and e for emacs
bindkey -e

# Load version control information
autoload -Uz vcs_info
precmd() {
  vcs_info
}

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{12}on branch%f %F{13}%b%f'

# Set up the prompt (with git branch name)
autoload -U promptinit
promptinit
setopt PROMPT_SUBST
PROMPT=' %F{11}%n%f %F{15}in %U${PWD/#$HOME/~}%u ${vcs_info_msg_0_} > '

## case-insensitive,partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# useful aliases
alias ls='ls -lah --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# enable useful packages (should be at the end)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
