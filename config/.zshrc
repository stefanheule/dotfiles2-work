
# ------------------------------------------------------------------------------
# zsh configuration

setopt histignorealldups nosharehistory

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# ------------------------------------------------------------------------------
# environment variables

if ! [[ -v DEVPOD_NAME ]]; then
  unset JAVA_HOME
  export JAVA8_HOME="$(/usr/libexec/java_home -v1.8)"
  export JAVA11_HOME="$(/usr/libexec/java_home -v11)"
  alias jdk_11='export JAVA_HOME="$JAVA11_HOME" && export PATH="$JAVA_HOME/bin:$PATH"'
  alias jdk_8='export JAVA_HOME="$JAVA8_HOME" && export PATH="$JAVA_HOME/bin:$PATH"'
  jdk_11
fi

path=(
  $HOME/dev/dotfiles2-work/bin
  $path
)

export COMMAND_NOT_FOUND_INSTALL_PROMPT=1

export EDITOR='nano'

export LESS='--quit-if-one-screen --mouse -iR --quiet'
if [[ -v DEVPOD_NAME ]]; then
  export LESS='-iR --quiet'
fi
export PAGER='less'

REPORTTIME=2

test -f ~/dev/dotfiles2-work/uber.sh && source ~/dev/dotfiles2-work/uber.sh

# some colors

typeset -A _COL_DATA
_COL_DATA=(
  'red' '\033[38;5;1m'
  'green' '\033[38;5;2m'
  'yellow' '\033[38;5;3m'
  'white' '\033[38;5;256m'
  'gray' '\033[38;5;244m'
  'light_gray' '\033[38;5;240m'
  'reset' '\033[0m'
  'dark_blue' '\033[38;5;19m'
  'light_blue' '\033[38;5;111m'
  'orange' '\033[38;5;172m'
  'dark_yellow' '\033[38;5;222m'
  'orange2' '\033[38;5;226m'
  'violet' '\033[38;5;183m'
  'pink' '\033[38;5;204m'
  'cyan' '\033[38;5;6m'
)

for k in "${(@k)_COL_DATA}"; do
  local uk=$(echo $k | tr '[:lower:]' '[:upper:]')
  export COL_$uk="$_COL_DATA[$k]"
  # COL2_* are the colors with the "char uses no space" annotation, to be used
  # in the prompt
  export COL2_$uk="%{$_COL_DATA[$k]%}"
done


# ------------------------------------------------------------------------------
# General helpers

alias sudo='sudo env PATH=$PATH'

# open $1 in EDITOR.
function e() {
  subl "$1"
  if [[ ! -d $1 ]]; then
    # "/mnt/c/Program Files/Sublime Text 3/subl.exe" -n `wslpath -a -w "$1"`
  else
    # "/mnt/c/Program Files/Sublime Text 3/subl.exe" -n `wslpath -a -w "$1"`
  fi
}

alias grep='grep --color=auto'
# export GREP_COLOR='37;45'

alias d='rm -r'

alias ai='sudo apt install'

alias l='ls -alhF --color=auto'
alias la='ls -aGhF --color=auto'
LS_COLORS='ln=38;5;129:ex=38;5;34:or=48;5;1:mi=38;5;241:fi=0:pi=38;5;172:so=38;5;172:bd=38;5;172:cd=38;5;172'
zstyle ':completion:*:default' list-colors 'di=38;5;27' ${(s.:.)LS_COLORS}
LS_COLORS="di=38;5;26m\033[1:$LS_COLORS"
export LS_COLORS

# finds files, looking at the full path
function f {
  tree -if --noreport | grep -i "$*"
}
# full path, also hidden files
function fh {
  tree -iaf --noreport | grep -i "$*"
}

alias u='sudo apt update && sudo apt upgrade'

# edit zsh config
alias ez="e ~/dev/dotfiles2-work/config/.zshrc"
function rz {
  source ~/.zshrc
}
function rzz {
  git -C ~/dev/dotfiles2-work pull
  source ~/.zshrc
}

# alias for opening things
# alias o='xdg-open'

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

# create a new directory, and move to it
function cdn () {
  mkdir -p "$1"
  cd "$1"
}
function mkdircd () {
  mkdir -p "$1"
  cd "$1"
}
alias mcd=mkdircd

# all colors
function colors() {
  for i in {0..255} ; do
    if (( i % 8 == 0 )); then
      printf "\n"
    fi
    printf "\x1b[38;5;${i}mcolour%03d  " $i
  done
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# helpers and aliases for financial choice
alias cdk='yarn cdk'

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
alias gaud='git add -u && git commit --amend --no-edit && arc diff'
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

bindkey '\eOA' history-substring-search-up
bindkey '\eOB' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
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
# Theme

# NO_GIT
# source ~/dev/dotfiles2-work/modules/gitstatus/gitstatus.plugin.zsh

setopt PROMPT_SUBST
prmopt_stefan() {
  # exit status
  local last_status=$?

  local pwdvar="${PWD/#$HOME/~}"
  local hnamee=$(hostname)
  local hname=${hnamee/stefanh-JXJGWL69YF/stefanh}
  if [[ -v DEVPOD_NAME ]]; then
    set_titlebar "$DEVPOD_NAME: ${pwdvar##*/}" 1
  else
    set_titlebar "local: ${pwdvar##*/}" 1
  fi
  

  local prefix=""
  if [[ "$pwdvar" =~ ^~/dev/nemo(/|$).*  ]]; then
    pwdvar="/${pwdvar:11}"
    prefix="[nemo]:"
  fi

  if [[ $last_status == 0 ]]; then
  else
    echo -n -e "[ %F{196}$last_status%f ] "
  fi

  local main_color="%F{37}" # teal
  [[ $hname != "stefanh" ]] && main_color="%F{160}" # red
  if [[ -v DEVPOD_NAME ]]; then
    main_color="%F{99}" # purple
    echo -n "${main_color}${hname}%f.devpod-us-or%f [${main_color}$DEVPOD_FLAVOR%f]"
  else
    echo -n "${main_color}${hname}"
  fi
  echo -n "%f @ %F{246}$prefix%f${main_color}${pwdvar}%f${GITSTATUS_PROMPT:+ $GITSTATUS_PROMPT}"
  echo -n "\n$"
}
PROMPT='$(prmopt_stefan) '

function set_titlebar {
  local title_bar=$1
  local output_nochar=$2
  case $TERM in
    xterm*)
      if [[ "$output_nochar" == 1 ]]; then
        echo -e -n "%{"
      fi
      echo -e -n "\033]0;$title_bar\007"
      if [[ "$output_nochar" == 1 ]]; then
        echo -e -n "%}"
      fi
      ;;
    screen*)
      if [[ "$output_nochar" == 1 ]]; then
        echo -e -n "%{"
      fi
      echo -e -n "\033k$title_bar\033\\"
      if [[ "$output_nochar" == 1 ]]; then
        echo -e -n "%}"
      fi
      ;;
    *) ;;
  esac
}


# Sets GITSTATUS_PROMPT to reflect the state of the current git repository. Empty if not
# in a git repository. In addition, sets GITSTATUS_PROMPT_LEN to the number of columns
# $GITSTATUS_PROMPT will occupy when printed.
#
# Example:
#
#   GITSTATUS_PROMPT='master ⇣42⇡42 ⇠42⇢42 *42 merge ~42 +42 !42 ?42'
#   GITSTATUS_PROMPT_LEN=39
#
#   master  current branch
#      ⇣42  local branch is 42 commits behind the remote
#      ⇡42  local branch is 42 commits ahead of the remote
#      ⇠42  local branch is 42 commits behind the push remote
#      ⇢42  local branch is 42 commits ahead of the push remote
#      *42  42 stashes
#    merge  merge in progress
#      ~42  42 merge conflicts
#      +42  42 staged changes
#      !42  42 unstaged changes
#      ?42  42 untracked files
function gitstatus_prompt_update() {
  emulate -L zsh
  typeset -g  GITSTATUS_PROMPT=''
  typeset -gi GITSTATUS_PROMPT_LEN=0

  # Call gitstatus_query synchronously. Note that gitstatus_query can also be called
  # asynchronously; see documentation in gitstatus.plugin.zsh.
  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local      clean='%7F'
  local   modified='%178F'
  local  untracked='%39F'
  local conflicted='%196F'

  local p

  p+=" %F{246}[%f "

  local where  # branch name, tag or commit
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+='%f#'
    where=$VCS_STATUS_TAG
  else
    p+='%f@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
  p+="${clean}${where//\%/%%}"             # escape %

  # ⇣42 if behind the remote.
  (( VCS_STATUS_COMMITS_BEHIND )) && p+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
  # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && p+=" "
  (( VCS_STATUS_COMMITS_AHEAD  )) && p+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  # ⇠42 if behind the push remote.
  (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && p+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
  (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && p+=" "
  # ⇢42 if ahead of the push remote; no leading space if also behind: ⇠42⇢42.
  (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && p+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
  # *42 if have stashes.
  (( VCS_STATUS_STASHES        )) && p+=" ${clean}*${VCS_STATUS_STASHES}"
  # 'merge' if the repo is in an unusual state.
  [[ -n $VCS_STATUS_ACTION     ]] && p+=" ${conflicted}${VCS_STATUS_ACTION}"
  # ~42 if have merge conflicts.
  (( VCS_STATUS_NUM_CONFLICTED )) && p+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  # +42 if have staged changes.
  (( VCS_STATUS_NUM_STAGED     )) && p+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  # !42 if have unstaged changes.
  (( VCS_STATUS_NUM_UNSTAGED   )) && p+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  # ?42 if have untracked files. It's really a question mark, your font isn't broken.
  (( VCS_STATUS_NUM_UNTRACKED  )) && p+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"

  p+=" %F{246}]"

  GITSTATUS_PROMPT="${p}%f"

  # The length of GITSTATUS_PROMPT after removing %f and %F.
  GITSTATUS_PROMPT_LEN="${(m)#${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}}"
}

# Start gitstatusd instance with name "MY". The same name is passed to
# gitstatus_query in gitstatus_prompt_update. The flags with -1 as values
# enable staged, unstaged, conflicted and untracked counters.
# NO_GIT
# gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

# On every prompt, fetch git status and set GITSTATUS_PROMPT.
autoload -Uz add-zsh-hook
# NO_GIT
# add-zsh-hook precmd gitstatus_prompt_update

# Enable/disable the right prompt options.
setopt no_prompt_bang prompt_percent prompt_subst



function bazel2 {
  WORKSPACE_ROOT=${WORKSPACE_ROOT:-$(git rev-parse --show-toplevel)}
  if [ ! -f "$WORKSPACE_ROOT/bazel-bin/tools/bazelbuild/wrapper/bazelwrapper" ]; then
    echo "BUILDING BAZEL WRAPPER FIRST"
    tools/bazel build tools/bazelbuild/wrapper:bazelwrapper
  fi
  "$WORKSPACE_ROOT/bazel-bin/tools/bazelbuild/wrapper/bazelwrapper" \
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

# load this last
source ~/dev/dotfiles2-work/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
