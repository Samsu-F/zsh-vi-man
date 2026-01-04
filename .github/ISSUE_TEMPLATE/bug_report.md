---
name: Bug Report
about: Report a bug or unexpected behavior
title: "[BUG] "
labels: bug
assignees: ""
---

## Description

A clear description of what the bug is.

## Steps to Reproduce

1. Type command: `...`
2. Press `Escape` to enter vi normal mode
3. Move cursor to `...`
4. Press `K`
5. See error...

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Environment

Please provide the following information:

**Zsh version:**

```bash
zsh --version
```

**Plugin configuration:**

```bash
echo "ZVM_MAN_KEY: $ZVM_MAN_KEY"
echo "ZVM_MAN_PAGER: $ZVM_MAN_PAGER"
echo "MANPAGER: $MANPAGER"
echo "PAGER: $PAGER"
echo "LESS: $LESS"
```

**Plugin manager:** (e.g., zinit, oh-my-zsh, manual)

**Other vi-mode plugins:**

- [ ] zsh-vi-mode
- [ ] Other (please specify):

**Operating System:**

- [ ] macOS (version: )
- [ ] Linux (distro: )
- [ ] Other:

## Additional Context

Add any other context about the problem here. Screenshots are helpful!

## Relevant Configuration

If applicable, share relevant parts of your `.zshrc`:

```zsh
# Your zsh-vi-man configuration
```
