# lib/parser.zsh - Word and command parsing utilities
# Extracts words and commands from the command line buffer

# Calculates the index of the token under the cursor within the tokenization
# (i.e. ${(z)myvar}) of the argument string
zvm_token_index_at_stringpos(){
  local line="$1"
  local stringpos="$2"
  local left="${line[1,stringpos]}"
  local right="${line[stringpos+1,-1]}"
  local right_tokens=(${(z)right})
  local first_right_token="${right_tokens[1]}"
  local left_tokens=(${(z)left})
  if [[ $left == *[[:space:]] ]] || (( ${#left_tokens} == 0 )); then
    left+="${first_right_token}"
    left_tokens=(${(z)left})
  fi
  echo ${#left_tokens}
}

# returns with status 0 iff $1 is a token that separates different segments, e.g. ';'
zvm_token_is_segment_separator() {
  case "$1" in
    '||'|'|'|'&'|'&&'|';'|'{'|'}'|'('|')'|'"')
      return 0
      ;;
  esac
  return 1
}

# Returns the command segment of the line $1 at stringpos $2.
# This function tries to avoid returning segments containing separator tokens and
# therefore, the returned segment may not necessarily be aroud stringpos.
# Does not descend into tokens that are nested commands.
zvm_segment_at_stringpos() {
  local line="$1"
  local stringpos=$2
  local -a tokens=(${(z)line})
  local last_token_idx=$(zvm_token_index_at_stringpos "$line" $stringpos)
  if zvm_token_is_segment_separator "${tokens[last_token_idx]}" && (( last_token_idx < ${#tokens} )); then
    (( last_token_idx++ )) # use the next segment e.g. if cursor is immediately after a semicolon
  fi
  while (( last_token_idx > 1 )) && zvm_token_is_segment_separator "${tokens[last_token_idx]}"; do
    (( last_token_idx-- )) # we don't want the result segment to end with a separator
  done
  local first_token_idx=$last_token_idx
  while (( first_token_idx > 1 )) && ! zvm_token_is_segment_separator "${tokens[first_token_idx-1]}"; do
    (( first_token_idx-- )) # previous token also belongs to the segment
  done
  local segment="${tokens[first_token_idx,last_token_idx]}"
  printf '%s' "$segment" # do not use echo here to prevent escape sequence interpretation
}

# Based on zvm_segment_at_stringpos but descends into nested subcommands
zvm_nested_segment_at_stringpos() {
  local string="$1"
  local stringpos=$2
  local segment="$(zvm_segment_at_stringpos "$string" $stringpos)"
  local -a segment_tokens=(${(z)segment})
  local last_segment_token="${segment_tokens[-1]}"
  local left="${string[1,stringpos]}"
  local -a left_tokens=(${(z)left})
  local last_left_token="${left_tokens[-1]}" # this is not necessarily part of the last segment token!
  while [[ "$last_left_token" =~ '^("?[^"`$]*\$\()(.*)$' || \
           "$last_left_token" =~ '^(<\()(.*)$' ]] && \
        [[ "$last_segment_token" == "$last_left_token"* ]]; do
    cutoff=${#match[1]} # the length of the prefix that we want to cut off. match is a special zsh variable
    string="${last_segment_token[cutoff+1,-1]}"
    stringpos=$(( ${#last_left_token} - cutoff ))
    # now update segment, last_left_token, and last_segment_token
    segment="$(zvm_segment_at_stringpos "$string" $stringpos)"
    segment_tokens=(${(z)segment})
    last_segment_token="${segment_tokens[-1]}"
    left="${string[1,stringpos]}"
    left_tokens=(${(z)left})
    last_left_token="${left_tokens[-1]}"
  done
  printf '%s' "$segment" # do not use echo here to prevent escape sequence interpretation
}

zvm_get_current_segment() {
  zvm_nested_segment_at_stringpos "$BUFFER" $CURSOR
}

# Determine the man page to open, checking for subcommands
# Input: $1 = command, $2 = current_segment
# Output: man page name (e.g., "git-commit" or just "git")
zvm_determine_man_page() {
  local cmd="$1"
  local segment="$2"
  local man_page="$cmd"
  
  local rest="${segment#*[[:space:]]}"
  local potential_subcommand="${rest%%[[:space:]]*}"
  
  # Check for subcommand man pages (e.g., git-commit, docker-run)
  if [[ -n "$potential_subcommand" && ! "$potential_subcommand" =~ ^- ]]; then
    if man -w "${cmd}-${potential_subcommand}" &>/dev/null; then
      man_page="${cmd}-${potential_subcommand}"
    fi
  fi
  
  echo "$man_page"
}

