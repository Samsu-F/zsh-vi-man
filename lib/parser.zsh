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

# returns with status 0 iff $1 is a reserved word in zsh that should be skipped by this plugin.
# e.g., if you type "if ! test -f", the man page for test should be opened on '-f', instead of
# searching for '-f' in the if man page, which is not even about the shell keyword 'if'
zvm_token_is_skipped_resword() {
  if (( $reswords[(Ie)$1] )) && ! man -w 1 $1 &>/dev/null; then
    return 0
  fi
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
  while (( first_token_idx < last_token_idx )) && zvm_token_is_skipped_resword "${tokens[first_token_idx]}"; do
    (( first_token_idx++ )) # current token is not part of the segment
  done
  local segment="${tokens[first_token_idx,last_token_idx]}"
  printf '%s' "$segment" # do not use echo here to prevent escape sequence interpretation
}

# in string $1, find the stringpos of the first unmatched closing ')' token.
# prints -1 iff there is no such token
# For example:
# input 'foo)bar'   --> output 4
# input '(x))bar'   --> output 4
# input 'echo ")")' --> output 9
# input 'echo ")"'  --> output -1
zvm_stringpos_of_closing_parenthesis() {
  local -i stringpos=1
  local -i nesting_depth=0
  local string="$1"
  while (( stringpos <= ${#string} )); do
    if [[ "${string[stringpos]}" == [[:space:]] ]]; then
      (( stringpos++ ))
      continue
    fi
    local -a tokens=(${(z)${string[stringpos,-1]}})
    local first_token="${tokens[1]}"
    if [[ "$first_token" == ')' ]] && (( nesting_depth == 0 )); then
      echo $stringpos
      return
    elif [[ "$first_token" == ')' ]]; then
      (( nesting_depth-- ))
      (( stringpos++ ))
    elif [[ "$first_token" == '(' ]]; then
      (( nesting_depth++ ))
      (( stringpos++ ))
    else
      (( stringpos+=${#first_token} ))
    fi
  done
  echo "-1"
}

# Based on zvm_segment_at_stringpos but descends into nested subcommands
zvm_nested_segment_at_stringpos() {
  local string="$1"
  local stringpos=$2
  local -i skipped_prefix=${3:-0}
  local segment="$(zvm_segment_at_stringpos "$string" $stringpos)"
  local -a segment_tokens=(${(z)segment})
  local last_segment_token="${segment_tokens[-1]}"
  local left="${string[1,stringpos]}"
  local -a left_tokens=(${(z)left})
  local last_left_token="${left_tokens[-1]}" # this is not necessarily part of the last segment token!
  if (( skipped_prefix == 0 )) && [[ "${last_left_token[1]}" == '"' ]]; then
    skipped_prefix=1
  fi
  if [[ "$last_segment_token" == "$last_left_token"* ]] && \
     [[ "$last_left_token" =~ '^(.{'"$skipped_prefix"'}[^"`$\\]*\$\().*$' || \
        "$last_left_token" =~ '^(<\().*$' ]]; then
    local cutoff=${#match[1]} # the length of the prefix that we want to cut off. match is a special zsh variable
    local remaining_suffix="${last_segment_token[cutoff+1,-1]}" # the part of the last segment token after the opening $( or <(
    local stringpos_in_rem_suffix=$(( ${#last_left_token} - cutoff ))
    local pos_closing_parenthesis="$(zvm_stringpos_of_closing_parenthesis "$remaining_suffix")"
    if (( pos_closing_parenthesis > 0 && pos_closing_parenthesis <= stringpos_in_rem_suffix )); then
      # if the command substituation found is closed to the left of stringpos
      zvm_nested_segment_at_stringpos "$1" $2 $(( cutoff + pos_closing_parenthesis ))
      return $?
    else # if stringpos is within the command substitution found ==> descend into nested command
      string="${remaining_suffix[1,pos_closing_parenthesis]}" # pos_closing_parenthesis may be -1 if it does not exist ==> until end
      zvm_nested_segment_at_stringpos "$string" $stringpos_in_rem_suffix 0
      return $?
    fi
  elif [[ "$last_segment_token" == "$last_left_token"* ]] && \
       { [[ "$last_left_token" =~ '^(.{'"$skipped_prefix"'}[^"`$\\]*\$[^"`\(\\]).*$' ]] || \
         [[ "$last_left_token" =~ '^(.{'"$skipped_prefix"'}[^"`$\\]*\\.).*$' ]] }; then
    # skip parameter expansion or backslash escaped character
    zvm_nested_segment_at_stringpos "$1" $2 ${#match[1]}
    return $?
  else
    printf '%s' "$segment" # do not use echo here to prevent escape sequence interpretation
  fi
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
  [[ "$cmd" == '[' ]] && cmd=test
  
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

