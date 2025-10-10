autoload -Uz compinit && compinit

# start fish only in interactive shell. 
[[ $- == *i* ]] && fish 

# create & edit a timestamped file, then copy its contents to the clipboard
newnote() {
  local prefix=${1:-note_}
  local ts=$(date +%Y%m%d_%H%M%S)
  local file="${prefix}${ts}.txt"

  vim "$file" && {
    if command -v pbcopy &>/dev/null; then
      pbcopy <"$file"
    fi
    echo "✔  $file → clipboard"
  }
}

alias nn=newnote
