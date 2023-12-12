#!/bin/bash

base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
here=$(basename "$base")
if [ "$here" = "dotfiles2" ]; then
  other="dotfiles2-work"
else
  other="dotfiles2"
fi

# loop through hidden files
shopt -s dotglob

function main {
  if [[ ! -d "$HOME/dev/$here" ]]; then
    error "Could not find 'here'=$here"
  fi
  if [[ ! -d "$HOME/dev/$other" ]]; then
    error "Could not find 'here'=$other"
  fi

  if [[ "$1" = "import" ]]; then
    src="$HOME/dev/$other"
    dest="$HOME/dev/$here"
    comment "Refreshing git in $src\n"
    git -C "$src" pull --recurse-submodules=on-demand
  elif [[ "$1" = "export" ]]; then
    src="$HOME/dev/$here"
    dest="$HOME/dev/$other"
  else
    error "Usage: $0 [import|export]"
  fi

  green "Copying from $src to $dest\n"

  comment "Copying config/\n"
  for path in $src/config/*; do
    local file=${path##*/}
    if [[ "$file" == ".aws" || "$file" == ".ssh" ]]; then
      continue
    fi
    if [[ "$file" == ".env.stefan.zsh" || "$file" == ".gitconfig" || "$file" == ".nvmrc" ]]; then
      continue
    fi
    
    comment "- config/$file\n"
    rm -rf "$dest/config/$file"
    cp -r "$src/config/$file" "$dest/config/$file"
  done

  for path in "bin" ".gitignore" "copy.sh" "install.sh" "zsh"; do
    if [[ "$path" == "install.sh" && "$1" = "import" ]]; then
      comment "Skipping $path on import\n"
      continue
    fi
    comment "Copying $path\n"
    rm -rf "$dest/$path"
    cp -r "$src/$path" "$dest/$path"
  done

  if ! diff <(sed 's|git@github.com:|https://github.com/|g' $HOME/dev/dotfiles2/.gitmodules) $HOME/dev/dotfiles2-work/.gitmodules; then
    error 'There are some modules that only exist in one of the repos, please fix this manually. Examples:
  git submodule add https://github.com/stefanheule/smartless.git modules/smartless
  git submodule add git@github.com:stefanheule/smartless.git modules/smartless'
  fi

  if ! diff <(git -C "$src" submodule foreach 'echo $path `git rev-parse HEAD`' | grep -v Entering) <(git -C "$dest" submodule foreach 'echo $path `git rev-parse HEAD`' | grep -v Entering); then
    error 'There are some modules that have different commits, please fix this manually.'
  fi
  

  if [[ "$2" = "push" ]]; then
    comment "Updateing my own submodules to head\n"
    git -C "$src"  submodule update --remote modules/zsh-llm-suggestions
    git -C "$dest" submodule update --remote modules/zsh-llm-suggestions
    git -C "$src"  submodule update --remote modules/smartless
    git -C "$dest" submodule update --remote modules/smartless
    comment "Committing and pushing $src\n"
    git -C "$src" add -A && git -C "$src" commit -m "copy.sh export push (src)"
    git -C "$src" push --recurse-submodules=on-demand
    comment "Committing and pushing $dest\n"
    git -C "$dest" add -A && git -C "$dest" commit -m "copy.sh export push (dest)"
    git -C "$dest" push --recurse-submodules=on-demand
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

main $1 $2
