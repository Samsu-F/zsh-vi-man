#!/usr/bin/env zsh
# Test script for emacs mode and vi insert mode support

echo "Testing zsh-vi-man mode support..."
echo

# Source the plugin
source "${0:h}/zsh-vi-man.zsh"

# Test 1: Check if the widget is registered
echo "✓ Test 1: Widget registration"
if zle -l | grep -q "zvm-man"; then
  echo "  PASS: zvm-man widget is registered"
else
  echo "  FAIL: zvm-man widget not found"
fi
echo

# Test 2: Check vicmd binding
echo "✓ Test 2: Vi normal mode binding"
if bindkey -M vicmd | grep -q "zvm-man"; then
  echo "  PASS: Key bound in vicmd mode"
  bindkey -M vicmd | grep "zvm-man"
else
  echo "  FAIL: No binding in vicmd mode"
fi
echo

# Test 3: Check emacs binding
echo "✓ Test 3: Emacs mode binding"
if bindkey -M emacs | grep -q "zvm-man"; then
  echo "  PASS: Key bound in emacs mode"
  bindkey -M emacs | grep "zvm-man"
else
  echo "  FAIL: No binding in emacs mode"
fi
echo

# Test 4: Check viins binding
echo "✓ Test 4: Vi insert mode binding"
if bindkey -M viins | grep -q "zvm-man"; then
  echo "  PASS: Key bound in viins mode"
  bindkey -M viins | grep "zvm-man"
else
  echo "  FAIL: No binding in viins mode"
fi
echo

# Test 5: Test with emacs mode disabled
echo "✓ Test 5: Disabling emacs mode"
ZVM_MAN_ENABLE_EMACS=false
_zvm_man_bind_key
if bindkey -M emacs | grep -q "zvm-man"; then
  echo "  FAIL: Key still bound in emacs mode (should be disabled)"
else
  echo "  PASS: Emacs mode binding correctly disabled"
fi
echo

# Test 6: Test with insert mode disabled
echo "✓ Test 6: Disabling vi insert mode"
ZVM_MAN_ENABLE_INSERT=false
_zvm_man_bind_key
if bindkey -M viins | grep -q "zvm-man"; then
  echo "  FAIL: Key still bound in viins mode (should be disabled)"
else
  echo "  PASS: Vi insert mode binding correctly disabled"
fi
echo

echo "All tests completed!"

