#!/bin/bash

base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
home="$HOME/"
backup="$HOME/dotfile-backup-$(date '+%Y-%m-%d')"
backup_used="no"

# loop through hidden files
shopt -s dotglob

function main {
  green "Linking configs to $home\n"
  local config="$base/config"
  for path in $config/*; do
    local file=${path##*/}
    if [[ "$file" == "sublime" ]]; then
      continue
    fi
    
    comment "~/$file: "
    if [ -f "$path" ]; then
      link_file "$home/$file" $path
    elif [ -d "$path" ]; then
      link_dir "$file" $path
    else
      error "File $path is neither a file nor a directory."
    fi
  done

  link_sublime_settings

  if [ $backup_used = "yes" ]; then
    blue "Backed up some files, check $backup\n"
  fi
}

function link_sublime_settings {
  cp "$base/config/sublime/Default (Windows).sublime-keymap" "$base/config/sublime/Default (Linux).sublime-keymap"
  cp "$base/config/sublime/Default (Windows).sublime-keymap" "$base/config/sublime/Default (OSX).sublime-keymap"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/ctrl/super/g' "$base/config/sublime/Default (OSX).sublime-keymap"
  else
    sed -i 's/ctrl/super/g' "$base/config/sublime/Default (OSX).sublime-keymap"
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    dst_path=$HOME/.config/sublime-text/Packages/User/
    dst_path_settings=$dst_path/Preferences.sublime-settings
    dst_path_keys=$dst_path/Default\ \(Linux\).sublime-keymap
    src_path_keys="$base/config/sublime/Default (Linux).sublime-keymap"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    dst_path="$HOME/Library/Application Support/Sublime Text/Packages/User"
    dst_path_settings="$dst_path/Preferences.sublime-settings"
    dst_path_keys="$dst_path/Default (OSX).sublime-keymap"
    src_path_keys="$base/config/sublime/Default (OSX).sublime-keymap"
  else
    error "unknown OS"
  fi

  if [ ! -f "$dst_path_settings" ] || [ ! -f "$dst_path_keys" ]; then
    blue "sublime not installed, not setting up sublime settings"
    return
  fi

  comment "sublime/Default.sublime-keymap: "
  link_file "$dst_path_keys" "$src_path_keys"
  comment "sublime/Preferences.sublime-settings: "
  link_file "$dst_path_settings" "$base/config/sublime/Preferences.sublime-settings"
}

function backup {
  local path=$1
  local file=${path##*/}
  mkdir -p "$backup"
  mv "$path" "$backup/$file"
  backup_used="yes"
}

function link_dir {
  comment "(directory, symlinking contents)\n"
  local dirname=$1
  local source_dir_path=$2
  local home_dir_path="$home$dirname/"
  mkdir -p "$home_dir_path"
  for path in $source_dir_path/*; do
    local file=${path##*/}
    comment "  - $file: "
    link_file "$home_dir_path$file" "$path"
  done
}

function link_file {
  local link_location=$1
  local link_destination=$2
  if [ -L "$link_location" ]; then
    if [ "$(readlink -f "$link_location")" = "$link_destination" ]; then
      green "already linked"
    else
      blue "link was $(readlink -f "$link_location"), fixing"
      rm "$link_location"
      ln -s "$link_destination" "$link_location"
    fi
  elif [ -f "$link_location" ]; then
    blue "backing up and symlinking"
    backup "$link_location"
    ln -s "$link_destination" "$link_location"
  else
    blue "symlinking"
    ln -s "$link_destination" "$link_location"
  fi
  echo ""
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