#!/usr/bin/env zsh
# Unit tests for neovim pattern generation
# Run: zsh test_nvim.zsh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Source the pattern module
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/lib/pattern.zsh"

# Test helper - check pattern is non-empty for given input
assert_pattern_generated() {
  local word="$1"
  local description="$2"
  
  local pattern=$(zvm_build_nvim_pattern "$word")
  
  if [[ -n "$pattern" ]]; then
    echo "${GREEN}✓${NC} $description"
    ((PASSED++))
  else
    echo "${RED}✗${NC} $description (pattern is empty)"
    echo "  Word: $word"
    ((FAILED++))
  fi
}

assert_pattern_empty() {
  local word="$1"
  local description="$2"
  
  local pattern=$(zvm_build_nvim_pattern "$word")
  
  if [[ -z "$pattern" ]]; then
    echo "${GREEN}✓${NC} $description"
    ((PASSED++))
  else
    echo "${RED}✗${NC} $description (pattern should be empty)"
    echo "  Word: $word"
    echo "  Pattern: $pattern"
    ((FAILED++))
  fi
}

# Convert vim regex pattern to grep ERE
# Vim uses \+ \| \( \) where ERE uses + | ( )
vim_to_grep() {
  echo "$1" | sed -e 's/\\+/+/g' -e 's/\\|/|/g' -e 's/\\(/(/g' -e 's/\\)/)/g'
}

# Test that pattern matches expected text
# Converts vim pattern to grep-compatible (handles basic vim regex)
assert_vim_matches() {
  local word="$1"
  local text="$2"
  local description="$3"
  
  local pattern=$(zvm_build_nvim_pattern "$word")
  local grep_pattern=$(vim_to_grep "$pattern")
  
  if echo "$text" | grep -qE "$grep_pattern"; then
    echo "${GREEN}✓${NC} $description"
    ((PASSED++))
  else
    echo "${RED}✗${NC} $description"
    echo "  Word: $word"
    echo "  Vim Pattern: $pattern"
    echo "  Grep Pattern: $grep_pattern"
    echo "  Text: $text"
    ((FAILED++))
  fi
}

assert_vim_no_match() {
  local word="$1"
  local text="$2"
  local description="$3"
  
  local pattern=$(zvm_build_nvim_pattern "$word")
  local grep_pattern=$(vim_to_grep "$pattern")
  
  if echo "$text" | grep -qE "$grep_pattern"; then
    echo "${RED}✗${NC} $description (should NOT match)"
    echo "  Word: $word"
    echo "  Text: $text"
    ((FAILED++))
  else
    echo "${GREEN}✓${NC} $description"
    ((PASSED++))
  fi
}

echo "${YELLOW}========================================${NC}"
echo "${YELLOW}  Neovim Pattern Generation Tests${NC}"
echo "${YELLOW}========================================${NC}"
echo

# ============================================
# Pattern Generation Tests
# ============================================
echo "${YELLOW}--- Pattern Generation Tests ---${NC}"

# Empty input
assert_pattern_empty "" "Empty word returns empty pattern"

# Single short option
assert_pattern_generated "-l" "Pattern generated for -l"
assert_pattern_generated "-r" "Pattern generated for -r"
assert_pattern_generated "-v" "Pattern generated for -v"

# Long option without value
assert_pattern_generated "--recursive" "Pattern generated for --recursive"
assert_pattern_generated "--verbose" "Pattern generated for --verbose"
assert_pattern_generated "--help" "Pattern generated for --help"

# Long option with value
assert_pattern_generated "--color=always" "Pattern generated for --color=always"
assert_pattern_generated "--format=json" "Pattern generated for --format=json"

# Combined short options
assert_pattern_generated "-la" "Pattern generated for -la"
assert_pattern_generated "-rf" "Pattern generated for -rf"
assert_pattern_generated "-xvf" "Pattern generated for -xvf"

echo

# ============================================
# Single Short Option Matching Tests
# ============================================
echo "${YELLOW}--- Single Short Option Matching Tests ---${NC}"

# Should match - option at start of line (after whitespace)
assert_vim_matches "-l" \
  "     -l      (The lowercase letter ell.)" \
  "-l: matches option at line start"

assert_vim_matches "-l" \
  "     -l, --long    Use long format" \
  "-l: matches option followed by comma"

assert_vim_matches "-l" \
  "       -l   Description" \
  "-l: matches with variable indentation"

# Note: Options after commas (like "-a, -l") won't match -l directly
# User can press 'n' in vim to find these. This avoids false positives.

# Should NOT match - description text (doesn't start with whitespace + dash at beginning)
assert_vim_no_match "-l" \
  "Use -l for listing" \
  "-l: ignores option in sentence (no leading whitespace)"

assert_vim_no_match "-l" \
  "the -l option is useful" \
  "-l: ignores inline mention without leading whitespace"

# These are the false positive cases from the user's report
assert_vim_no_match "-l" \
  "     -f      This option turns on the -l option." \
  "-l: ignores -l mentioned in description of -f option"

assert_vim_no_match "-l" \
  "             the effect of the -r, -l and -t options." \
  "-l: ignores continuation line (starts with spaces, no dash)"

assert_vim_no_match "-l" \
  "     -n      Display (-l) output." \
  "-l: ignores -l in parentheses within different option"

echo

# ============================================
# Long Option Matching Tests
# ============================================
echo "${YELLOW}--- Long Option Matching Tests ---${NC}"

# Should match - option at start of line
assert_vim_matches "--recursive" \
  "     --recursive    Recurse into directories" \
  "--recursive: matches at line start"

assert_vim_matches "--recursive" \
  "     --recursive, --recurse" \
  "--recursive: matches with comma after"

# Note: --recursive after comma (like "-R, -r, --recursive") won't match directly
# User can press 'n' in vim to find it on that line. This avoids false positives.

# Should NOT match
assert_vim_no_match "--recursive" \
  "Use --recursive to recurse" \
  "--recursive: ignores inline mention"

assert_vim_no_match "--recursive" \
  "             Use the --recursive option for deep search" \
  "--recursive: ignores mention in continuation line"

echo

# ============================================
# Long Option with Value Matching Tests
# ============================================
echo "${YELLOW}--- Long Option with Value Matching Tests ---${NC}"

assert_vim_matches "--color=always" \
  "     --color=WHEN    Colorize output" \
  "--color=always: matches --color option"

# Note: --color after comma won't match directly - user presses 'n' in vim

echo

# ============================================
# Combined Options Matching Tests
# ============================================
echo "${YELLOW}--- Combined Options Matching Tests ---${NC}"

# For -la, should match both -l and -a at line start
assert_vim_matches "-la" \
  "     -l      Long format" \
  "-la: matches -l at line start"

assert_vim_matches "-la" \
  "     -a      Show all" \
  "-la: matches -a at line start"

# For -rf, should match -r and -f at line start
assert_vim_matches "-rf" \
  "     -r      Recursive" \
  "-rf: matches -r definition"

assert_vim_matches "-rf" \
  "     -f      Force" \
  "-rf: matches -f definition"

# Note: Options after commas won't match directly - user presses 'n' in vim

echo

# ============================================
# Edge Cases
# ============================================
echo "${YELLOW}--- Edge Case Tests ---${NC}"

# Tab indentation
assert_vim_matches "-v" \
  "	-v      Verbose" \
  "-v: matches with tab indentation"

# Multiple spaces
assert_vim_matches "-v" \
  "       -v   Description" \
  "-v: matches with variable indentation"

# Options at line start
assert_vim_matches "-s" \
  "     -s: Description" \
  "-s: matches at line start with colon after"

assert_vim_matches "-s" \
  "     -s, --slurp" \
  "-s: matches at line start"

echo

# ============================================
# Real Man Page Excerpts
# ============================================
echo "${YELLOW}--- Real Man Page Excerpt Tests ---${NC}"

# ls -l format
assert_vim_matches "-l" \
  "     -l      (The lowercase letter \"ell\".)  List files in the long format" \
  "ls -l: matches real ls format"

# grep -R (at line start)
assert_vim_matches "-R" \
  "     -R, -r, --recursive" \
  "grep -R: matches at line start"

# git -v (at line start)
assert_vim_matches "-v" \
  "       -v, --verbose" \
  "git -v: matches at line start"

# jq --slurp (at line start)
assert_vim_matches "--slurp" \
  "       --slurp / -s:" \
  "jq --slurp: matches at line start"

echo

# ============================================
# False Positive Prevention Tests
# ============================================
echo "${YELLOW}--- False Positive Prevention Tests ---${NC}"

# From user's report: these should NOT match
assert_vim_no_match "-l" \
  "     -f      Output is not sorted.  This option turns on -a.  It also negates the effect of the -r, -S and -t options." \
  "-l not in this text at all"

# Continuation lines don't start with whitespace+dash
assert_vim_no_match "-l" \
  "             1003.1-2008 (\"POSIX.1\"), this option has no effect on the -d, -l, -R and -s options." \
  "-l: continuation line mentioning -l should not match"

assert_vim_no_match "-l" \
  "     -n      Display user and group IDs numerically rather than converting to a user or group name in a long (-l) output." \
  "-l: parenthetical mention in -n description should not match"

# User's original bug report: ls -f description mentions -d, -l, -R (should NOT match -l)
# This was matching because the old pattern "-.*[,/]" was too greedy
assert_vim_no_match "-l" \
  "     -f      Output is not sorted.  This option turns on -a.  It also negates the effect of the -r, -S and -t options.  As allowed by IEEE Std 1003.1-2008 (\"POSIX.1\"), this option has no effect on the -d, -l, -R and -s options." \
  "-l: ls -f description mentioning -d, -l, -R should not match (original bug report)"

echo

# ============================================
# Comparison with Less Patterns
# ============================================
echo "${YELLOW}--- Less Pattern Comparison Tests ---${NC}"

# Ensure both pattern builders return non-empty for same inputs
test_words=("-l" "-r" "--recursive" "--color=always" "-rf" "-la")
for word in "${test_words[@]}"; do
  less_pattern=$(zvm_build_less_pattern "$word")
  nvim_pattern=$(zvm_build_nvim_pattern "$word")
  
  if [[ -n "$less_pattern" && -n "$nvim_pattern" ]]; then
    echo "${GREEN}✓${NC} Both patterns generated for: $word"
    ((PASSED++))
  else
    echo "${RED}✗${NC} Pattern missing for: $word"
    echo "  Less: ${less_pattern:-<empty>}"
    echo "  Nvim: ${nvim_pattern:-<empty>}"
    ((FAILED++))
  fi
done

echo

echo "${YELLOW}--- Bug Fix Tests (nvim-results.md) ---${NC}"

# Test 2: --recursive after comma should now match
assert_vim_matches "--recursive" \
  "     -R, -r, --recursive" \
  "bug fix: --recursive matches after comma in -R, -r, --recursive"

# Test 3: -r after pipe context - pattern should find -r in man page
assert_vim_matches "-r" \
  "     -R, -r, --recursive" \
  "bug fix: -r matches in grep man page"

# Test 4: find-style -name should match
assert_vim_matches "-name" \
  "       -name pattern" \
  "bug fix: -name matches find-style option"

assert_vim_matches "-exec" \
  "       -exec utility [argument ...] ;" \
  "bug fix: -exec matches find-style option"

# Test: --slurp should NOT match --slurpfile (word boundary)
assert_vim_no_match "--slurp" \
  "       --slurpfile variable file:" \
  "bug fix: --slurp does NOT match --slurpfile"

# But --slurp should match --slurp itself
assert_vim_matches "--slurp" \
  "       --slurp / -s:" \
  "bug fix: --slurp matches --slurp / -s:"

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
