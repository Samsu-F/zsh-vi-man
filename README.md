<div align="center">

# 📖 zsh-vi-man

**Smart man page lookup for zsh vi mode (now with emacs mode support!)**

Press `K` (vi normal mode), `Ctrl-X k` (emacs mode), or `Ctrl-K` (vi insert mode) on any command or option to instantly open its man page

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Zsh](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)
[![Tests](https://github.com/TunaCuma/zsh-vi-man/workflows/Tests/badge.svg)](https://github.com/TunaCuma/zsh-vi-man/actions)

<br>

<img src="demo.gif" alt="zsh-vi-man demo" width="700">

</div>

<br>

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎯 Smart Detection

Automatically finds the right man page for subcommands

```
git commit → man git-commit
docker run → man docker-run
```

</td>
<td width="50%">

### 🔍 Option Jumping

Opens man page directly at the option definition

```
grep -r    → jumps to -r entry
ls --color → jumps to --color entry
```

</td>
</tr>
<tr>
<td width="50%">

### 🔗 Combined Options

Works with combined short options

```
rm -rf    → finds both -r and -f
tar -xvf  → finds -x, -v, -f
```

</td>
<td width="50%">

### 📝 Value Extraction

Handles options with values

```
--color=always     → searches --color
--output=file.txt  → searches --output
```

</td>
</tr>
<tr>
<td width="50%">

### 🔀 Pipe Support

Detects correct command in pipelines

```
cat file | grep -i  → opens man grep
tree | less -N      → opens man less
```

</td>
<td width="50%">

### 🛠️ Multiple Formats

Supports various man page styles

```
GNU: -R, -r, --recursive
jq:  --slurp / -s:
find: -name, -type, -exec
```

</td>
</tr>
</table>

<br>

## 📦 Installation

<details open>
<summary><b>zinit</b></summary>

```zsh
zinit light TunaCuma/zsh-vi-man
```

</details>

<details>
<summary><b>antidote</b></summary>

Add to your `.zsh_plugins.txt`:

```
TunaCuma/zsh-vi-man
```

</details>

<details>
<summary><b>oh-my-zsh</b></summary>

```bash
git clone https://github.com/TunaCuma/zsh-vi-man \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-man
```

Then add to your `.zshrc`:

```zsh
plugins=(... zsh-vi-man)
```

</details>

<details>
<summary><b>Manual</b></summary>

```bash
git clone https://github.com/TunaCuma/zsh-vi-man ~/.zsh-vi-man
echo 'source ~/.zsh-vi-man/zsh-vi-man.plugin.zsh' >> ~/.zshrc
```

</details>

<br>

## 🚀 Usage

### Vi Normal Mode (Default)

1. Type a command (e.g., `ls -la` or `git commit --amend`)
2. Press `Escape` to enter vi normal mode
3. Move cursor to any word
4. Press **`K`** to open the man page

### Emacs Mode / Vi Insert Mode

Without leaving insert mode or if using emacs mode:
- **Emacs mode**: Press **`Ctrl-X`** then **`k`**
- **Vi insert mode**: Press **`Ctrl-K`**

<br>

### Examples

| Command                | Cursor On      | Result                               |
| :--------------------- | :------------- | :----------------------------------- |
| `ls -la`               | `ls`           | Opens `man ls`                       |
| `ls -la`               | `-la`          | Opens `man ls`, jumps to `-l`        |
| `git commit --amend`   | `commit`       | Opens `man git-commit`               |
| `grep --color=auto`    | `--color=auto` | Opens `man grep`, jumps to `--color` |
| `cat file \| sort -r`  | `-r`           | Opens `man sort`, jumps to `-r`      |
| `find . -name "*.txt"` | `-name`        | Opens `man find`, jumps to `-name`   |

<br>

## ⚙️ Configuration

Set these variables **before** sourcing the plugin:

```zsh
# Vi normal mode key (default: K)
ZVM_MAN_KEY='?'

# Emacs mode key sequence (default: ^Xk, i.e., Ctrl-X k)
ZVM_MAN_KEY_EMACS='^X^K'  # Example: Ctrl-X Ctrl-K

# Vi insert mode key (default: ^K, i.e., Ctrl-K)
ZVM_MAN_KEY_INSERT='^H'   # Example: Ctrl-H

# Enable/disable emacs mode binding (default: true)
ZVM_MAN_ENABLE_EMACS=false

# Enable/disable vi insert mode binding (default: true)
ZVM_MAN_ENABLE_INSERT=false

# Use a different pager (default: less)
ZVM_MAN_PAGER='bat'
```

### Troubleshooting

**Keybindings not working?**

If keybindings don't work after sourcing the plugin, try running:

```zsh
zvm_man_rebind
```

This can happen if:
- Your plugin manager loads plugins before setting up keymaps
- You call `bindkey -e` or `bindkey -v` after the plugin loads
- Another plugin resets your keybindings

**For persistent issues**, add this to your `.zshrc` **after** sourcing the plugin:

```zsh
# Ensure zsh-vi-man bindings are set
zvm_man_rebind
```

<details>
<summary><b>Key Binding Examples</b></summary>

| Key Notation | Description |
|:-------------|:------------|
| `^K` | Ctrl-K |
| `^Xk` | Ctrl-X then k |
| `^X^K` | Ctrl-X then Ctrl-K |
| `\ek` | Alt-k (or Escape then k) |

For special keys, use zsh notation: `^[` for Escape, `^?` for Backspace, etc.

</details>

<br>

## 🔌 Integration with zsh-vi-mode

This plugin works seamlessly with [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode). It automatically detects zsh-vi-mode and hooks into its lazy keybindings system.

For best results, source this plugin **after** zsh-vi-mode:

```zsh
source /path/to/zsh-vi-mode.zsh
source /path/to/zsh-vi-man.zsh
```

<br>

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

```bash
# Run tests
zsh test_patterns.zsh

# Test locally
source ./zsh-vi-man.plugin.zsh
```

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

<div align="center">

---

Made with ❤️ by [Tuna Cuma](https://github.com/TunaCuma)

</div>
