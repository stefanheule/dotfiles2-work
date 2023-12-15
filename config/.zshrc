
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

if [[ $- == *i* ]]; then
  export STEFAN_IS_INTERACTIVE=1
else
  export STEFAN_IS_INTERACTIVE=0
fi

if [[ $STEFAN_IS_WORK -eq 1 ]]; then
  if [[ $STEFAN_IS_DEVPOD -eq 0 ]]; then
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

if [[ $(uname) == "Darwin" ]]; then
  export STEFAN_IS_OSX=1
  export STEFAN_IS_DEBIAN_10=0
  export STEFAN_IS_WSL=0
else
  export STEFAN_IS_OSX=0
  if grep -q WSL2 /proc/version; then
    export STEFAN_IS_WSL=1
  else
    export STEFAN_IS_WSL=0
  fi
  if grep -q 'PRETTY_NAME="Debian GNU/Linux 10 (buster)"' /etc/os-release; then
    export STEFAN_IS_DEBIAN_10=1
  else
    export STEFAN_IS_DEBIAN_10=0
  fi
fi


local full_hostname=$(hostname)
export STEFAN_HOSTNAME=${full_hostname/stefanh-JXJGWL69YF/stefanh}

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

test -f ~/dev/$STEFAN_DOTFILES_REPO_NAME/config/local.zsh && source ~/dev/$STEFAN_DOTFILES_REPO_NAME/config/local.zsh

# hack to source /etc/environment on WSL
if [[ $STEFAN_IS_WSL -eq 1 ]]; then
  for env in $( cat /etc/environment | tail -n +2 ); do export $(echo $env | sed -e 's/"//g'); done
fi

# some colors
export COL_GREEN='\033[38;5;2m'
export COL_RESET='\033[0m'

export TIMEFMT=$(echo -n -e "\n${COL_GREEN}Command finished in (real: %*E, user: %*U, kernel: %*S), using %K KiB$COL_RESET")

# good colors for LS
# Generated with dircolors -b, but inlined due to OSX not having dircolors
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';


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
  git -C ~/dev/$STEFAN_DOTFILES_REPO_NAME submodule update --init --recursive
  rz
  ~/dev/$STEFAN_DOTFILES_REPO_NAME/install.sh
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

function colors() {
  for i in {0..255} ; do
    printf "\x1b[38;5;${i}m%3d " "${i}"
    if (( $i == 15 )) || (( $i > 15 )) && (( ($i-15) % 12 == 0 )); then
      echo;
    fi
  done
}

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
bindkey "^[s" sudo-command-line # alt+s to insert sudo
bindkey "^[alt-s" sudo-command-line

# Ctrl+Z to push the current command on a stack, and restore after the next command
fancy-ctrl-z() {
  zle push-input
}
zle -N fancy-ctrl-z
if [[ $STEFAN_IS_INTERACTIVE -eq 1 ]] && [[ "$NO_GITSTATUS" != "yes" ]]; then
  stty -ixon # disable ctrl+q for normal use
fi
bindkey '^Q' fancy-ctrl-z


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
# ZSH llm suggestions

if [[ -d ~/dev/zsh-llm-suggestions/ ]]; then
  source ~/dev/zsh-llm-suggestions/zsh-llm-suggestions.zsh
else
  source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-llm-suggestions/zsh-llm-suggestions.zsh
fi
bindkey '^o' zsh_llm_suggestions_openai # Ctrl + O to have OpenAI suggest a command given a English description
bindkey '^[^o' zsh_llm_suggestions_openai_explain # Ctrl + alt + O to have OpenAI explain a command
bindkey '^[ctrl-alt-o' zsh_llm_suggestions_openai_explain
bindkey '^p' zsh_llm_suggestions_github_copilot # Ctrl + P to have GitHub Copilot suggest a command given a English description
bindkey '^[^p' zsh_llm_suggestions_github_copilot_explain # Ctrl + alt + P to have GitHub Copilot explain a command
bindkey '^[ctrl-alt-p' zsh_llm_suggestions_github_copilot_explain

# demo mode for zsh-llm-suggestions
# source ~/dev/zsh-llm-suggestions/zsh-llm-suggestions-demo.zsh
# bindkey '^o' zsh_llm_suggestions_demo
# ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c1,)" # disable autosuggestions for demo mode

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


# ------------------------------------------------------------------------------
# Auto sugestions

# Start with history suggestions, then fall back to completion suggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion) 
# Don't use history for cd, because it's not context sensitive
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
# Don't complete things that are more than 50 characters
[[ ! -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]] && ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)"
source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^I' autosuggest-accept # use tab to accept suggestion
bindkey '^.' expand-or-complete # bind regular complete to ctrl+.
bindkey '^[ctrl-dot' expand-or-complete

# ------------------------------------------------------------------------------
# Syntax highlighting and substring search (load these last)

source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history substring search
source ~/dev/$STEFAN_DOTFILES_REPO_NAME/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '\eOA' history-substring-search-up
bindkey '\eOB' history-substring-search-down
