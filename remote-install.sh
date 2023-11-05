#!/bin/bash

set -e

base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
home="$HOME"

function main {
  if [ -d "$home/dev/dotfiles2-work" ]; then
    error "~/dev/dotfiles2-work already exsits. delete it first, then re-run."
  else
    mkdir -p $home/dev
    green "Cloning dotfiles..."
    git clone --recurse-submodules https://github.com/stefanheule/dotfiles2-work.git $home/dev/dotfiles2-work
    green "Running ./install..."
    cd $home/dev/dotfiles2-work
    ./install.sh
    green "Reloading zsh config..."
    source $home/.zshrc
    green "Done with remote installation."
  fi
}

RED="\033[38;5;1m"
GREEN="\033[38;5;2m"
BLUE="\033[38;5;4m"
GRAY="\033[38;5;8m"
NOCOLOR="\033[0m"
function comment {
  echo -e -n "${GRAY}$@${NOCOLOR}"
}
function green {
  echo -e -n "${GREEN}$@${NOCOLOR}"
}
function blue {
  echo -e -n "${BLUE}$@${NOCOLOR}"
}
function error {
  echo ""
  echo -e "${RED}:: $@${NOCOLOR}"
  exit 1
}

main
