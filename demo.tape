# VHS Demo Tape for zsh-vi-man
# Run: vhs demo.tape
# https://github.com/TunaCuma/zsh-vi-man

Output demo.gif

Set Shell zsh
Set FontSize 18
Set Width 900
Set Height 500
Set Padding 20
Set TypingSpeed 60ms

# Source zshrc (hidden from demo)
Hide
Type "source ~/.zshrc"
Enter
Type "clear"
Enter
Sleep 2s
Show

# ============================================
# Demo 1: Basic short option (-l)
# ============================================
Sleep 1s
Type "# Press K on an option to jump to its man page entry"
Sleep 2s
Ctrl+Space
Sleep 500ms

Type "ls -la"
Sleep 1.5s
Ctrl+C
Sleep 300ms
# Move to -s and press K
Set TypingSpeed 200ms
Type "h"
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
# Navigate in man page
Set TypingSpeed 200ms
Type "n"
Sleep 400ms
Type "n"
Sleep 400ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Demo 2: Long option (--recursive)
# ============================================
Type "i"
Type "# Works with long options too"
Sleep 1.5s
Ctrl+Space
Sleep 500ms

Type "grep --recursive pattern ."
Sleep 1.5s
Ctrl+C
Sleep 300ms
# Move to --recursive
Set TypingSpeed 200ms
Type "Bhh"
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
Set TypingSpeed 200ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Demo 3: Git subcommand support
# ============================================
Type "i"
Type "# Supports subcommands like git-commit"
Sleep 1.5s
Ctrl+Space
Sleep 500ms

Type "git commit --amend"
Sleep 1.5s
Ctrl+C
Sleep 300ms
Set TypingSpeed 200ms
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
Set TypingSpeed 200ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Demo 4: Piped commands
# ============================================
Type "i"
Type "# Detects correct command in pipes"
Sleep 1.5s
Ctrl+Space
Sleep 500ms

Type "find . | grep -i pattern"
Sleep 1.5s
Ctrl+C
Sleep 300ms
# Cursor is on -i, should open grep man page
Set TypingSpeed 200ms
Type "bb"
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
Set TypingSpeed 200ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Demo 5: find-style options (-name)
# ============================================
Type "i"
Type "# Handles find-style single-dash long options"
Sleep 1.5s
Ctrl+Space
Sleep 500ms

Type "find . -name '*.txt' -type f"
Sleep 1.5s
Ctrl+C
Sleep 300ms
# Move to -name
Set TypingSpeed 200ms
Type "BBhh"
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
Set TypingSpeed 200ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Demo 6: Option with value (--color=always)
# ============================================
Type "i"
Type "# Extracts option from --option=value"
Sleep 1.5s
Ctrl+Space
Sleep 500ms

Type "ls --color=always"
Sleep 1.5s
Ctrl+C
Sleep 300ms
Set TypingSpeed 200ms
Type "bhh"
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
Set TypingSpeed 200ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Demo 7: Combined options (-rf)
# ============================================
Type "i"
Type "# Combined options find individual entries"
Sleep 1.5s
Ctrl+Space
Sleep 500ms

Type "rm -rf /tmp/test"
Sleep 1.5s
Ctrl+C
Sleep 300ms
Set TypingSpeed 200ms
Type "Bhh"
Sleep 200ms
Type "K"
Set TypingSpeed 60ms
Sleep 2.5s
# Shows both -r and -f matches
Set TypingSpeed 200ms
Type "n"
Sleep 500ms
Type "q"
Set TypingSpeed 60ms
Sleep 1s
Ctrl+Space
Sleep 500ms

# ============================================
# Outro
# ============================================
Type "i"
Type "# zsh-vi-man: Smart man page lookup for vi mode"
Sleep 2s
Ctrl+Space
Sleep 3s
