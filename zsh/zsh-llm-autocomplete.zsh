
zsh_llm_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

zsh_llm_query() {
  local llm="$1"
  local query="$2"
  local completion_file="$3"
  echo -n "$query" | eval $llm > $completion_file
}

zsh_llm_completion() {
  local llm="$1"
  local query=${BUFFER}
  if [[ "$query" == "" ]]; then
    return
  fi
  if [[ "$query" == "$STEFAN_LLM_LAST_RESULT" ]]; then
    # The user wants another completion, because the current one is no good
    query=$STEFAN_LLM_LAST_QUERY
  fi
  export STEFAN_LLM_LAST_QUERY="$query"

  local completion_file="/tmp/llm-completion"
  # echo -ne "\e[5 q"
  # completion=$(echo -n "$query" | eval $llm)
  # Your long-running process here &
  read < <( zsh_llm_query $llm $query $completion_file & echo $! )
  # Get the PID of the process
  local pid=$REPLY
  # Call the spinner function and pass the PID
  zsh_llm_spinner $pid
  
  export STEFAN_LLM_LAST_RESULT=$(cat $completion_file)
  BUFFER="${STEFAN_LLM_LAST_RESULT}"
  CURSOR=${#STEFAN_LLM_LAST_RESULT}
}

zsh_openai_completion() {
  zsh_llm_completion "~/dev/$STEFAN_DOTFILES_REPO_NAME/zsh/zsh-openai.py"
}

zsh_github_copilot_completion() {
  zsh_llm_completion "~/dev/$STEFAN_DOTFILES_REPO_NAME/zsh/zsh-github-copilot.py"
}

zle -N zsh_openai_completion
zle -N zsh_github_copilot_completion
