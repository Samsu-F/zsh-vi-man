# lib/pager.zsh - Pager-specific man page opening logic
# Handles different pagers: less, nvim, vim, etc.

# Detect the pager type from ZVM_MAN_PAGER
# Output: "nvim", "vim", "less", or "other"
zvm_detect_pager_type() {
  local pager_basename="${ZVM_MAN_PAGER##*/}"
  
  if [[ "$pager_basename" =~ ^nvim ]]; then
    echo "nvim"
  elif [[ "$pager_basename" =~ ^vim$ ]]; then
    echo "vim"
  elif [[ "$pager_basename" =~ ^less$ ]]; then
    echo "less"
  else
    echo "other"
  fi
}

# Open man page with neovim
# Uses neovim's built-in Man command with search
# Input: $1 = man_page, $2 = search_pattern (vim regex, optional)
# Returns: 0 on success, 1 on failure
zvm_open_nvim() {
  local man_page="$1"
  local search_term="$2"
  
  # Run nvim exactly as user would: nvim +"Man <cmd>" +only +/<search>
  # No stdin/stdout/stderr redirects - let nvim have full terminal access
  # This prevents issues with plugins like image.nvim that need terminal size
  # Set MANWIDTH to a large number to prevent line wrapping in man pages
  if [[ -n "$search_term" ]]; then
    MANWIDTH=999 ${ZVM_MAN_PAGER} +"Man ${man_page}" +only +"/${search_term}" || \
      MANWIDTH=999 ${ZVM_MAN_PAGER} +"Man ${man_page}" +only || \
      return 1
  else
    MANWIDTH=999 ${ZVM_MAN_PAGER} +"Man ${man_page}" +only || \
      return 1
  fi
  
  return 0
}

# Open man page with less or other traditional pagers
# Uses the -p flag for pattern search
# Input: $1 = man_page, $2 = search_pattern (ERE, optional)
# Returns: 0 on success, 1 on failure
zvm_open_less() {
  local man_page="$1"
  local pattern="$2"
  
  if [[ -n "$pattern" ]]; then
    man "$man_page" 2>/dev/null | ${ZVM_MAN_PAGER} -p "${pattern}" 2>/dev/null || \
      man "$man_page" 2>/dev/null | ${ZVM_MAN_PAGER} || \
      return 1
  else
    man "$man_page" 2>/dev/null || return 1
  fi
  
  return 0
}

# Main entry point: open man page with appropriate pager
# Automatically detects pager type and uses correct pattern format
# Input: $1 = man_page, $2 = word (for pattern building)
# Returns: 0 on success, 1 on failure
zvm_open_man_page() {
  local man_page="$1"
  local word="$2"
  local pager_type
  
  pager_type=$(zvm_detect_pager_type)
  
  case "$pager_type" in
    nvim|vim)
      local nvim_pattern
      nvim_pattern=$(zvm_build_nvim_pattern "$word")
      zvm_open_nvim "$man_page" "$nvim_pattern"
      ;;
    less|other)
      local less_pattern
      less_pattern=$(zvm_build_less_pattern "$word")
      zvm_open_less "$man_page" "$less_pattern"
      ;;
  esac
}

