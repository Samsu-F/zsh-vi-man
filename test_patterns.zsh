#!/usr/bin/env zsh
# Unit tests for zsh-vi-man pattern matching
# Run: zsh test_patterns.zsh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Test helper functions
assert_matches() {
  local pattern="$1"
  local text="$2"
  local description="$3"
  
  if echo "$text" | grep -qE "$pattern"; then
    echo "${GREEN}✓${NC} $description"
    ((PASSED++))
  else
    echo "${RED}✗${NC} $description"
    echo "  Pattern: $pattern"
    echo "  Text: $text"
    ((FAILED++))
  fi
}

assert_no_match() {
  local pattern="$1"
  local text="$2"
  local description="$3"
  
  if echo "$text" | grep -qE "$pattern"; then
    echo "${RED}✗${NC} $description (should NOT match)"
    echo "  Pattern: $pattern"
    echo "  Text: $text"
    ((FAILED++))
  else
    echo "${GREEN}✓${NC} $description"
    ((PASSED++))
  fi
}

# Build pattern for single short option (e.g., -l)
# Supports comma-separated (GNU) and slash-separated (jq) styles
build_short_option_pattern() {
  local word="$1"
  echo "^[[:space:]]*${word}[,/:[:space:]]|^[[:space:]]*-.*[,/][[:space:]]+${word}([,/:[:space:]]|$)"
}

# Build pattern for long option (e.g., --recursive)
build_long_option_pattern() {
  local word="$1"
  echo "^[[:space:]]*${word}([,/=:[[:space:]]|$)|^[[:space:]]*-.*[,/][[:space:]]+${word}([,/=:[[:space:]]|$)"
}

# Build pattern for long option with value (e.g., --color=always -> --color)
build_long_option_value_pattern() {
  local opt="$1"
  echo "^[[:space:]]*${opt}([,/=:[[:space:]]|$)|^[[:space:]]*-.*[,/][[:space:]]+${opt}([,/=:[[:space:]]|$)"
}

# Build pattern for combined short options (e.g., -rf)
# Also includes fallback for single-dash long options like find's -name
build_combined_option_pattern() {
  local word="$1"
  local chars="$2"
  # Pattern 1: individual chars (e.g., -r or -f from -rf)
  # Pattern 2: the full word as-is (e.g., -name for find)
  echo "^[[:space:]]*-[${chars}][,/:[:space:]]|^[[:space:]]*-.*[,/][[:space:]]+-[${chars}][,/:[:space:]]|^[[:space:]]*${word}([,/:[:space:]]|$)|^[[:space:]]*-.*[,/][[:space:]]+${word}([,/:[:space:]]|$)"
}

echo "${YELLOW}========================================${NC}"
echo "${YELLOW}  zsh-vi-man Pattern Matching Tests${NC}"
echo "${YELLOW}========================================${NC}"
echo

# ============================================
# Single Short Option Tests (-l, -r, etc.)
# ============================================
echo "${YELLOW}--- Single Short Option Tests ---${NC}"

pattern=$(build_short_option_pattern "-l")

# Should match
assert_matches "$pattern" \
  "     -l      (The lowercase letter ell.)" \
  "-l: matches option at line start"

assert_matches "$pattern" \
  "     -l, --long    Use long format" \
  "-l: matches option followed by comma"

assert_matches "$pattern" \
  "     -a, -l, --long    Multiple options" \
  "-l: matches option in middle of list"

assert_matches "$pattern" \
  "       -l   Description" \
  "-l: matches with variable indentation"

# Should NOT match
assert_no_match "$pattern" \
  "     -@      Display extended attribute keys and sizes in long (-l) output." \
  "-l: ignores option mentioned in parentheses"

assert_no_match "$pattern" \
  "             the effect of the -r, -l and -t options." \
  "-l: ignores option mentioned in description text"

assert_no_match "$pattern" \
  "     -f      This option turns on -l." \
  "-l: ignores option mentioned at end of description"

assert_no_match "$pattern" \
  "             Use -l for long listing" \
  "-l: ignores option in continuation line"

echo

# ============================================
# Short Option in Multi-Option Line (-r in -R, -r, --recursive)
# ============================================
echo "${YELLOW}--- Short Option in Multi-Option Line Tests ---${NC}"

pattern=$(build_short_option_pattern "-r")

# Should match
assert_matches "$pattern" \
  "     -R, -r, --recursive" \
  "-r: matches in -R, -r, --recursive"

assert_matches "$pattern" \
  "     -r      Recursive mode" \
  "-r: matches at line start"

assert_matches "$pattern" \
  "     -R, -r    Two options" \
  "-r: matches after single preceding option"

# Should NOT match
assert_no_match "$pattern" \
  "             the effect of the -r, -S and -t options." \
  "-r: ignores mention in description"

assert_no_match "$pattern" \
  "             Recursively search using -r flag" \
  "-r: ignores mention in continuation"

echo

# ============================================
# Long Option Tests (--recursive, --verbose)
# ============================================
echo "${YELLOW}--- Long Option Tests ---${NC}"

pattern=$(build_long_option_pattern "--recursive")

# Should match
assert_matches "$pattern" \
  "     -R, -r, --recursive" \
  "--recursive: matches at end of option list"

assert_matches "$pattern" \
  "     --recursive    Recurse into directories" \
  "--recursive: matches at line start"

assert_matches "$pattern" \
  "     --recursive, --recurse    Aliases" \
  "--recursive: matches followed by comma"

assert_matches "$pattern" \
  "       --recursive" \
  "--recursive: matches alone on line"

# Should NOT match
assert_no_match "$pattern" \
  "             Use --recursive for subdirectories" \
  "--recursive: ignores mention in description"

assert_no_match "$pattern" \
  "             the --recursive option enables deep search" \
  "--recursive: ignores mention in continuation"

echo

# ============================================
# Long Option with Value (--color=always -> --color)
# ============================================
echo "${YELLOW}--- Long Option with Value Tests ---${NC}"

pattern=$(build_long_option_value_pattern "--color")

# Should match
assert_matches "$pattern" \
  "     --color=WHEN    Colorize output" \
  "--color: matches --color=WHEN"

assert_matches "$pattern" \
  "     --color[=WHEN]    Optional value" \
  "--color: matches --color[=WHEN]"

assert_matches "$pattern" \
  "     -c, --color    Short and long" \
  "--color: matches after short option"

assert_matches "$pattern" \
  "     --color    Without value" \
  "--color: matches without value"

# Should NOT match
assert_no_match "$pattern" \
  "             Set --color=always for colored output" \
  "--color: ignores in description"

echo

# ============================================
# Combined Short Options (-rf -> -r and -f)
# ============================================
echo "${YELLOW}--- Combined Short Options Tests ---${NC}"

pattern=$(build_combined_option_pattern "-rf" "rf")

# Should match (finds -r or -f)
assert_matches "$pattern" \
  "     -r      Recursive" \
  "-rf: matches -r definition"

assert_matches "$pattern" \
  "     -f      Force" \
  "-rf: matches -f definition"

assert_matches "$pattern" \
  "     -R, -r, --recursive" \
  "-rf: matches -r in option list"

# Should also match the literal -rf (for some commands that document combined options)
assert_matches "$pattern" \
  "     -rf     Remove recursively with force" \
  "-rf: matches -rf literally as fallback"

# Should NOT match
assert_no_match "$pattern" \
  "             the -r and -f options" \
  "-rf: ignores mention in description"

echo

# ============================================
# Single-dash Long Options (find -name, -type)
# ============================================
echo "${YELLOW}--- Single-dash Long Options (find style) Tests ---${NC}"

# -name from find
pattern=$(build_combined_option_pattern "-name" "name")

assert_matches "$pattern" \
  "       -name pattern" \
  "-name: matches find-style option"

assert_matches "$pattern" \
  "       -name" \
  "-name: matches alone on line"

# Also matches individual letters as fallback
assert_matches "$pattern" \
  "     -n      Dry run" \
  "-name: also matches -n as fallback"

# -type from find
pattern=$(build_combined_option_pattern "-type" "type")

assert_matches "$pattern" \
  "       -type c" \
  "-type: matches find-style -type"

# -exec from find  
pattern=$(build_combined_option_pattern "-exec" "exec")

assert_matches "$pattern" \
  "       -exec utility [argument ...] ;" \
  "-exec: matches find-style -exec"

# Should NOT match in description
assert_no_match "$pattern" \
  "             Use -exec to run commands" \
  "-exec: ignores mention in description"

echo

# ============================================
# Edge Cases
# ============================================
echo "${YELLOW}--- Edge Case Tests ---${NC}"

# Tab indentation
pattern=$(build_short_option_pattern "-v")
assert_matches "$pattern" \
  "	-v      Verbose mode" \
  "-v: matches with tab indentation"

# No indentation (some man pages)
assert_matches "$pattern" \
  "-v      Verbose mode" \
  "-v: matches with no indentation"

# Multiple spaces in option list
pattern=$(build_long_option_pattern "--verbose")
assert_matches "$pattern" \
  "     -v,  --verbose    With extra space" \
  "--verbose: matches with extra spaces"

# Option at very end of line
pattern=$(build_short_option_pattern "-z")
assert_matches "$pattern" \
  "     -a, -b, -z" \
  "-z: matches at end of line (no trailing space)"

# Numeric options
pattern=$(build_short_option_pattern "-1")
# Note: Current pattern only matches [a-zA-Z], but let's test anyway
# This tests what the actual code would do

echo

# ============================================
# jq-style Slash-Separated Options
# ============================================
echo "${YELLOW}--- jq-style Slash-Separated Options Tests ---${NC}"

# --slurp / -s style from jq
pattern=$(build_long_option_pattern "--slurp")
assert_matches "$pattern" \
  "       --slurp / -s:" \
  "--slurp: matches jq-style --option / -x:"

pattern=$(build_short_option_pattern "-s")
assert_matches "$pattern" \
  "       --slurp / -s:" \
  "-s: matches jq-style --option / -x:"

# More jq examples
pattern=$(build_long_option_pattern "--raw-output")
assert_matches "$pattern" \
  "       --raw-output / -r:" \
  "--raw-output: matches jq raw-output style"

pattern=$(build_short_option_pattern "-r")
assert_matches "$pattern" \
  "       --raw-output / -r:" \
  "-r: matches after slash in jq style"

pattern=$(build_short_option_pattern "-n")
assert_matches "$pattern" \
  "       --null-input / -n:" \
  "-n: matches jq null-input style"

# Should NOT match slash in description text
assert_no_match "$pattern" \
  "             Use -n / -r for different outputs" \
  "-n: ignores slash-separated mention in description"

echo

# ============================================
# Real Man Page Excerpts
# ============================================
echo "${YELLOW}--- Real Man Page Excerpt Tests ---${NC}"

# From ls(1)
pattern=$(build_short_option_pattern "-l")
assert_matches "$pattern" \
  "     -l      (The lowercase letter \"ell\".)  List files in the long format, as
             described in the The Long Format subsection below." \
  "ls -l: matches real ls man page format"

assert_no_match "$pattern" \
  "     -f      Output is not sorted.  This option turns on -a.  It also negates
             the effect of the -r, -S and -t options.  As allowed by IEEE Std
             1003.1-2008 (\"POSIX.1\"), this option has no effect on the -d, -l,
             -R and -s options." \
  "ls -f: does not match -l mentioned in -f description"

# From grep(1)
pattern=$(build_long_option_pattern "--recursive")
assert_matches "$pattern" \
  "     -R, -r, --recursive
             Recursively search subdirectories listed.  (i.e., force grep to
             behave as rgrep)." \
  "grep --recursive: matches real grep man page format"

# From git(1) style
pattern=$(build_long_option_pattern "--verbose")
assert_matches "$pattern" \
  "       -v, --verbose
           Be more verbose." \
  "--verbose: matches git-style man page format"

echo

# ============================================
# Pipe Command Extraction Tests
# ============================================
echo "${YELLOW}--- Pipe Command Extraction Tests ---${NC}"

# Helper to extract command from LBUFFER (simulating cursor position)
extract_cmd_from_lbuffer() {
  local LBUFFER="$1"
  local current_segment="${LBUFFER##*|}"
  current_segment="${current_segment#"${current_segment%%[![:space:]]*}"}"
  local cmd="${current_segment%%[[:space:]]*}"
  echo "$cmd"
}

# Simple command (no pipe)
result=$(extract_cmd_from_lbuffer "ls -la")
if [[ "$result" == "ls" ]]; then
  echo "${GREEN}✓${NC} Simple command: ls -la → ls"
  ((PASSED++))
else
  echo "${RED}✗${NC} Simple command: ls -la → expected 'ls', got '$result'"
  ((FAILED++))
fi

# Piped command - cursor after pipe
result=$(extract_cmd_from_lbuffer "tree | grep -")
if [[ "$result" == "grep" ]]; then
  echo "${GREEN}✓${NC} Piped command: tree | grep - → grep"
  ((PASSED++))
else
  echo "${RED}✗${NC} Piped command: tree | grep - → expected 'grep', got '$result'"
  ((FAILED++))
fi

# Multiple pipes - cursor at end
result=$(extract_cmd_from_lbuffer "cat file | sort | uniq -")
if [[ "$result" == "uniq" ]]; then
  echo "${GREEN}✓${NC} Multiple pipes: cat file | sort | uniq - → uniq"
  ((PASSED++))
else
  echo "${RED}✗${NC} Multiple pipes: cat file | sort | uniq - → expected 'uniq', got '$result'"
  ((FAILED++))
fi

# Cursor before pipe (should get first command)
result=$(extract_cmd_from_lbuffer "ls -la")
if [[ "$result" == "ls" ]]; then
  echo "${GREEN}✓${NC} Before pipe: ls -la → ls"
  ((PASSED++))
else
  echo "${RED}✗${NC} Before pipe: ls -la → expected 'ls', got '$result'"
  ((FAILED++))
fi

# Command with subcommand after pipe
result=$(extract_cmd_from_lbuffer "echo hello | git status")
if [[ "$result" == "git" ]]; then
  echo "${GREEN}✓${NC} Subcommand after pipe: echo hello | git status → git"
  ((PASSED++))
else
  echo "${RED}✗${NC} Subcommand after pipe: echo hello | git status → expected 'git', got '$result'"
  ((FAILED++))
fi

# Edge case: just after pipe with space
result=$(extract_cmd_from_lbuffer "ls | ")
if [[ "$result" == "" ]]; then
  echo "${GREEN}✓${NC} Just after pipe: ls |  → (empty, no command yet)"
  ((PASSED++))
else
  echo "${RED}✗${NC} Just after pipe: ls |  → expected '', got '$result'"
  ((FAILED++))
fi

echo
echo "${YELLOW}========================================${NC}"
echo "${YELLOW}  Test Results${NC}"
echo "${YELLOW}========================================${NC}"
echo "  ${GREEN}Passed: $PASSED${NC}"
echo "  ${RED}Failed: $FAILED${NC}"
echo

if [[ $FAILED -eq 0 ]]; then
  echo "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo "${RED}Some tests failed!${NC}"
  exit 1
fi

