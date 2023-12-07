
source ~/.env.stefan.zsh

# ------------------------------------------------------------------------------
# zsh configuration

setopt histignorealldups nosharehistory extendedhistory incappendhistorytime

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# ------------------------------------------------------------------------------
# environment variables

if [[ ! -n $DEVPOD_NAME ]]; then
    export STEFAN_IS_DEVPOD=0
else
    export STEFAN_IS_DEVPOD=1
fi

if [[ $STEFAN_IS_WORK -eq 1 ]]; then
  if [[ $STEFAN_IS_DEVPOD -eq 1 ]]; then
    unset JAVA_HOME
    export JAVA8_HOME="$(/usr/libexec/java_home -v1.8)"
    export JAVA11_HOME="$(/usr/libexec/java_home -v11)"
    alias jdk_11='export JAVA_HOME="$JAVA11_HOME" && export PATH="$JAVA_HOME/bin:$PATH"'
    alias jdk_8='export JAVA_HOME="$JAVA8_HOME" && export PATH="$JAVA_HOME/bin:$PATH"'
    jdk_11
  fi

  path=(
    $HOME/dev/$STEFAN_DOTFILES_REPO_NAME/bin
    $path
  )
else
  export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
  export ANDROID_HOME=/home/stefan/dev/Android
  export ANDROID_SDK_ROOT=/home/stefan/dev/Android

  path=(
    /snap/bin
    /usr/local/{bin,sbin}
    $HOME/dev/$STEFAN_DOTFILES_REPO_NAME/bin
    $JAVA_HOME/bin
    $ANDROID_HOME/emulator
    $ANDROID_HOME/tools
    $ANDROID_HOME/tools/bin
    $ANDROID_HOME/cmdline-tools/latest
    $ANDROID_HOME/cmdline-tools/latest/bin
    $ANDROID_HOME/platform-tools
    $HOME/.local/bin
    $HOME/.yarn/bin
    $path
  )
fi

if grep -q 'PRETTY_NAME="Debian GNU/Linux 10 (buster)"' /etc/os-release; then
    export STEFAN_IS_DEBIAN_10=1
else
    export STEFAN_IS_DEBIAN_10=0
fi

export EDITOR='nano'

export LESS='--quit-if-one-screen --mouse -iR --quiet'
export PAGER='less'
if [[ $STEFAN_IS_DEBIAN_10 -eq 1 ]]; then
  # Debian 10 has an ancient version of less
  export PAGER='smartless'
  export LESS='-iR --quiet'
  export SMARTLESS_NUM_LINES=15
  export SMARTLESS_PAGER_ARGUMENTS='-iR --quiet'
fi

# test -f ~/dev/$STEFAN_DOTFILES_REPO_NAME/zsh/local-repo.sh && source ~/dev/$STEFAN_DOTFILES_REPO_NAME/local-repo.sh

# hack to source /etc/environment on WSL
if grep -q WSL2 /proc/version; then
  for env in $( cat /etc/environment | tail -n +2 ); do export $(echo $env | sed -e 's/"//g'); done
fi

# some colors
export COL_GREEN='\033[38;5;2m'
export COL_RESET='\033[0m'

export TIMEFMT=$(echo -n -e "\n${COL_GREEN}Command finished in (real: %*E, user: %*U, kernel: %*S), using %K KiB$COL_RESET")

# good colors for LS
eval "$(dircolors -b)"


# ------------------------------------------------------------------------------
# General helpers

alias sudo='sudo env PATH=$PATH'

# open $1 in EDITOR.
function e() {
  subl "$1"
}

alias grep='grep --color=auto'
alias d='rm -r'
alias ai='sudo apt install'
alias l='ls -alhF --color=auto'
alias la='ls -aGhF --color=auto'

# finds files, looking at the full path
function f { tree -if --noreport | grep -i "$*" }
# full path, also hidden files
function fh { tree -iaf --noreport | grep -i "$*" }

alias u='sudo apt update && sudo apt upgrade'

# edit zsh config
alias ez="e ~/dev/$STEFAN_DOTFILES_REPO_NAME"
function rz {
  source ~/.zshrc
}
function rzz {
  git -C ~/dev/$STEFAN_DOTFILES_REPO_NAME pull
  git submodule update --init --recursive
  rz
}

# alias for opening things
# alias o='xdg-open'
function o() {
  local path=$(wslpath -w "$1")
  /mnt/c/Users/stefan/Dropbox/links/laptop-usability/win-tweaks/open-helper/open.exe "$path"
}

# create a temporary directory
alias tmp='(echo $PWD > /tmp/stefan-tmp-last-dir.txt) && cd $(mktemp -d)'
function deltmp {
  local dtmp
  dtmp=$(pwd)
  echo -e -n "Press [Enter] to remove '${COL_GREEN}$dtmp${COL_RESET}' (Ctrl+C to quit)."
  read
  cd ..
  rm -rf $dtmp
  cd "$(cat /tmp/stefan-tmp-last-dir.txt)"
  rm -f "/tmp/stefan-tmp-last-dir.txt"
}

alias doc='sudo docker'
alias dc='sudo docker-compose -f /home/stefan/www/terra/docker/docker-compose.yml'
alias dcup='sudo docker-compose -f /home/stefan/www/terra/docker/docker-compose.yml up -d --remove-orphans'
alias dcpull='sudo docker-compose -f /home/stefan/www/terra/docker/docker-compose.yml pull'
alias dcupdate='dcpull; dcup'
alias dcdown='sudo docker-compose -f /home/stefan/www/terra/docker/docker-compose.yml down'

# -g alias helpers
typeset -A abbrevs
abbrevs=('...' '../..'
  '....' '../../..'
  'C' '| wc -l'
  'G' '|& grep'
  'GA' '|& grep -A 5'
  'GB' '|& grep -B 5'
  'GC' '|& grep -C 5'
  'U' '| sort | uniq'
  'CU' '| sort | uniq -c'
  'UC' '| sort | uniq -c'
  'L' '| less'
  'M' '| more'
  'N' '&>/dev/null'
  'NE' '2>/dev/null'
  'NO' '>/dev/null'
  'S' '| sort -u'
)
for abbr in ${(k)abbrevs}; do
  alias -g $abbr="${abbrevs[$abbr]}"
done

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# ------------------------------------------------------------------------------
# git shortcuts

alias g='git'
alias gb='git branch'
alias gp='git push --recurse-submodules=on-demand'
alias gpp='git push --recurse-submodules=on-demand --force'
alias gu='git pull'
alias gum='git pull origin main'
alias guu='git pull && git submodule update --recursive'
alias glog='git log --topo-order --pretty=format:"${_git_log_brief_format}"'
alias gcount='git shortlog --summary --numbered'
alias gs='echo "Branch: $(git branch --show-current)" && git status -s'
alias gd='git diff --no-ext-diff --word-diff=color'
alias gde='git diff' # uses external diff tool
alias ge='git commit --amend'
alias gau='git add -u && git commit --amend --no-edit'
alias gaa='git add -A && git commit --amend --no-edit'
alias ga='git add'
alias gm='git fetch && git merge origin/master'
function gcu {
  if [[ $# == 0 ]]; then
    git add -u && git commit -m "work in progress"
  else
    git add -u && git commit -m "$*"
  fi
}
function gca {
  if [[ $# == 0 ]]; then
    git add -A && git commit -m "work in progress"
  else
    git add -A && git commit -m "$*"
  fi
}
function gc {
  if [[ $# == 0 ]]; then
    git commit -m "work in progress"
  else
    git commit -m "$*"
  fi
}
function gcup {
  if [[ $# == 0 ]]; then
    git add -u && git commit -m "work in progress" && gp
  else
    git add -u && git commit -m "$*" && gp
  fi
}
function gcap {
  if [[ $# == 0 ]]; then
    git add -A && git commit -m "work in progress" && gp
  else
    git add -A && git commit -m "$*" && gp
  fi
}
function gcp {
  if [[ $# == 0 ]]; then
    git commit -m "work in progress" && gp
  else
    git commit -m "$*" && gp
  fi
}
alias gundo='git reset --soft HEAD~1 && git reset'
function gclean {
  git fetch -p > /dev/null
  local list=$(git branch -vv | grep ': gone]' | awk '{print $1}')
  if [[ "$list" = "" ]]; then
    echo "Already clean :)"
    return
  fi
  echo 'The following branches are deleted upstream, removing them now:'
  echo ${COL_GREEN}$list${COL_RESET}
  # echo '[Enter] for yes, Ctrl+C to quit.'
  # read
  echo $list | xargs -n 1 git branch -D
}
function gend {
  if [[ $# == 1 ]]; then
    echo -e -n "Press [Enter] to delete '${COL_GREEN}$1${COL_RESET}' (Ctrl+C to quit)."
    read
    git branch -d $1
  else
    if [[ $(git status --porcelain) ]]; then
      echo "not in a clean branch"
      return 1
    else
      branch=$(git rev-parse --abbrev-ref HEAD)
      echo -e -n "Press [Enter] to delete '${COL_GREEN}$branch${COL_RESET}' (Ctrl+C to quit)."
      read
      git checkout master
      git pull
      git branch -d $branch
    fi
  fi
}
alias glive='git push live master && gp'
alias gh='git checkout'

function gstart {
  if [[ $# == 1 ]]; then
    if [[ $(git ls-remote --heads origin $1) ]]; then
      echo -e "Branch '${COL_GREEN}$1${COL_RESET}' already exists on remote."
      return 1
    fi
    git checkout -b $1
    git push -u origin $1
  else
    echo "usage: gstart <branch-name>"
  fi
}

# space usage
alias space='du -hsx * | sort -rh | head -20'
alias space2='du -a . | sort -n -r | head -n 20'
alias spacesym='du -hsxL * | sort -rh | head -20'
alias space2sym='du -aL . | sort -n -r | head -n 20'
alias spaceall='df -kh'

# ------------------------------------------------------------------------------
# zsh hotkeys

# ctrl+space to expand aliases
expandalias() {
  zle beginning-of-line
  for ((i = 0; i < 50; i++)); do
    zle _expand_alias;
    zle forward-char;
  done
  zle end-of-line
}
zle -N expandalias
bindkey "^@" expandalias

# run command line as user root via sudo (using alt+s)
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
  zle end-of-line
}
zle -N sudo-command-line
bindkey "^[s" sudo-command-line

# Ctrl+Z to push the current command on a stack, and restore after the next command
fancy-ctrl-z() {
  zle push-input
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# ------------------------------------------------------------------------------
# Completion system

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} # colorful
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ------------------------------------------------------------------------------
# work specific

if [[ $STEFAN_IS_WORK -eq 1 ]]; then
  function bazel2 {
    WORKSPACE_ROOT=${WORKSPACE_ROOT:-$(git rev-parse --show-toplevel)}
    if [ ! -f "$WORKSPACE_ROOT/bazel-bin/tools/bazelbuild/wrapper/bazelwrapper" ]; then
      echo "BUILDING BAZEL WRAPPER FIRST"
      tools/bazel build tools/bazelbuild/wrapper:bazelwrapper
    fi
    RENOVATE_USE_GIT_HEAD=yes RENOVATE=yes "$WORKSPACE_ROOT/bazel-bin/tools/bazelbuild/wrapper/bazelwrapper" \
      "--wrapper-config-dir" "$WORKSPACE_ROOT/tools/bazelbuild/wrapper/config/development" \
      "--wrapper-cwd" "$WORKSPACE_ROOT"  \
      "$@"
  }

  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

  eval "$(direnv hook zsh)"

  alias rw='/usr/bin/osascript ~/dev/dotfiles2-work/scripts/move-windows.applescript'
  alias winget='/usr/bin/osascript ~/dev/dotfiles2-work/scripts/get-window-size-and-position.applescript'
fi

# ------------------------------------------------------------------------------
# Theme

# Load our theme
source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-async/async.zsh
source ~/dev/$STEFAN_DOTFILES_REPO_NAME/zsh/pure.zsh

# load these last
source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-history-substring-search/zsh-history-substring-search.zsh

# Setup keys after loading the module only
bindkey '\eOA' history-substring-search-up
bindkey '\eOB' history-substring-search-down
