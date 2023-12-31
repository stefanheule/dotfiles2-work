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

  local host=$(hostname)
  if [[ "$host" = "mercury" ]] || [[ "$host" = "carbon" ]]; then
    green "Personal computer; setting up apache2/nginx\n"

    comment "/etc/nginx/nginx.conf: "
    if [[ -d /etc/nginx ]]; then
      link_file "/etc/nginx/nginx.conf" "$base/config-other/nginx.conf" "sudo"
    else
      blue "nginx not installed\n"
    fi

    comment "/etc/apache2/apache2.conf: "
    if [[ -d /etc/apache2 ]]; then
      link_file "/etc/apache2/apache2.conf" "$base/config-other/apache2.conf" "sudo"

      comment "/etc/apache2/ports.conf: "
      link_file "/etc/apache2/ports.conf" "$base/config-other/apache2-ports.conf" "sudo"

      comment "/etc/apache2/sites-available/pages-www.conf: "
      link_file "/etc/apache2/sites-available/pages-www.conf" "$base/config-other/apache2-pages-www.conf" "sudo"
    else
      blue "apache2 not installed\n"
    fi

    comment "WSL host file: "
    link_file "/etc/hosts" "$base/config-other/hosts-wsl" "sudo"

    
    if ! link_file_windows "/mnt/c/Windows/System32/drivers/etc/hosts" "$base/config-other/hosts-windows" "Windows host file" "sudo-nomove"; then
      if [[ -f /mnt/c/tools/gsudo/Current/gsudo.exe ]]; then
        /mnt/c/tools/gsudo/Current/gsudo.exe -d "type \\\\wsl.localhost\Ubuntu\home\stefan\dev\dotfiles2\config-other\hosts-windows > %windir%\System32\drivers\etc\hosts"
      else
        blue "install gsudo using cholatey (/mnt/c/tools/gsudo/Current/gsudo.exe doesn't exists)\n"
      fi
    fi
  fi

  if [ $backup_used = "yes" ]; then
    blue "Backed up some files, check $backup\n"
  fi
}

function link_sublime_settings {
  cp "$base/config/sublime/Default (Windows).sublime-keymap" "$base/config/sublime/Default (Linux).sublime-keymap"
  cp "$base/config/sublime/Default (Windows).sublime-keymap" "$base/config/sublime/Default (OSX).sublime-keymap"
  cp "$base/config/sublime/Preferences.sublime-settings" "$base/config/sublime/Preferences-OSX.sublime-settings"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/ctrl/super/g' "$base/config/sublime/Default (OSX).sublime-keymap"
    sed -i '' 's/"font_size": 9,/"font_size": 12,/g' "$base/config/sublime/Preferences-OSX.sublime-settings"
  else
    sed -i 's/ctrl/super/g' "$base/config/sublime/Default (OSX).sublime-keymap"
    sed -i 's/"font_size": 9,/"font_size": 12,/g' "$base/config/sublime/Preferences-OSX.sublime-settings"
  fi

  local src_path_settings="$base/config/sublime/Preferences.sublime-settings"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    dst_path=$HOME/.config/sublime-text/Packages/User/
    dst_path_settings=$dst_path/Preferences.sublime-settings
    dst_path_keys=$dst_path/Default\ \(Linux\).sublime-keymap
    src_path_keys="$base/config/sublime/Default (Linux).sublime-keymap"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    src_path_settings="$base/config/sublime/Preferences-OSX.sublime-settings"
    dst_path="$HOME/Library/Application Support/Sublime Text/Packages/User"
    dst_path_settings="$dst_path/Preferences.sublime-settings"
    dst_path_keys="$dst_path/Default (OSX).sublime-keymap"
    src_path_keys="$base/config/sublime/Default (OSX).sublime-keymap"
  else
    error "unknown OS"
  fi

  if [ ! -d "$dst_path" ]; then
    blue "sublime not installed, not setting up sublime settings"
    return
  fi

  comment "sublime/Default.sublime-keymap: "
  link_file "$dst_path_keys" "$src_path_keys"
  comment "sublime/Preferences.sublime-settings: "
  link_file "$dst_path_settings" "$src_path_settings"

  if [ -n "$WSL_DISTRO_NAME" ]; then
    local wsl_path="/mnt/c/Users/stefan/AppData/Roaming/Sublime Text 3/Packages/User"
    local wsl_path_settings="/mnt/c/Users/stefan/AppData/Roaming/Sublime Text 3/Packages/User/Preferences.sublime-settings"
    local     wsl_path_keys="/mnt/c/Users/stefan/AppData/Roaming/Sublime Text 3/Packages/User/Default (Windows).sublime-keymap"
    local     src_path_keys="$base/config/sublime/Default (Windows).sublime-keymap"

    if [ ! -d "$wsl_path" ]; then
      # Try again with /Sublime Text/ instead of /Sublime Text 3/
      wsl_path=${wsl_path/ 3/}
      wsl_path_keys=${wsl_path_keys/ 3/}
      wsl_path_settings=${wsl_path_settings/ 3/}
      if [ ! -d "$wsl_path" ]; then
        blue "sublime on Windows not installed, not setting up sublime settings there\n"
        return
      fi
    fi

    link_file_windows "$wsl_path_settings" "$src_path_settings" "(Windows) sublime/Default.sublime-keymap"
    link_file_windows "$wsl_path_keys" "$src_path_keys" "(Windows) sublime/Default (Windows).sublime-keymap"
  fi
}

function link_file_windows {
  local dst="$1"
  local src="$2"
  local name="$3"
  local USE_SUDO=$4
  comment "$name: "
  if diff "$dst" "$src" > /dev/null 2>&1; then
    green "no changes, already correct\n"
  else
    blue "changes, backing up and copying over (cannot symlink to windows)\n"
    backup "$dst" "win_" $USE_SUDO
    if [[ "$USE_SUDO" = "sudo" ]] || [[ "$USE_SUDO" = "sudo-nomove" ]]; then
      return 1
    else
      cp "$src" "$dst"
    fi
  fi
  return 0
}

function backup {
  local path=$1
  local file=${path##*/}
  local prefix=$2
  local USE_SUDO=$3
  mkdir -p "$backup"
  if [[ -f "$backup/$prefix$file" ]]; then
    rm -f "$backup/$prefix$file"
  fi
  if [[ "$USE_SUDO" = "sudo-nomove" ]]; then
    cp "$path" "$backup/$prefix$file"
  else
    $USE_SUDO mv "$path" "$backup/$prefix$file"
  fi
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
  local USE_SUDO=$3
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
    backup "$link_location" "" $USE_SUDO
    $USE_SUDO ln -s "$link_destination" "$link_location"
  else
    blue "symlinking"
    $USE_SUDO ln -s "$link_destination" "$link_location"
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