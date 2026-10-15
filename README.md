# Dotfiles

## Structure

- caelestia/ - Caelestia shell config
- git/ - Global Git config & ignore files
- nvim/ - Neovim (init.lua + lazy-lock.json)
- vim/ - Vim config (.vimrc)
- wezterm/ - WezTerm terminal emulator configuration (cross-platform)
- zsh/ - Zsh config

## WezTerm Hotkeys

Leader Key: **`Ctrl + A`** (1-second timeout. Press `Ctrl + A` twice to pass `Ctrl + A` through to terminal apps).

### Panes (Tmux-style)

| Shortcut | Action |
| :--- | :--- |
| `Leader` + `\|` or `\` | Split pane horizontally (left / right) |
| `Leader` + `-` | Split pane vertically (top / bottom) |
| `Leader` + `h` / `j` / `k` / `l` or `Arrows` | Navigate between panes |
| `Leader` + `Shift` + `H` / `J` / `K` / `L` | Resize active pane |
| `Leader` + `z` | Toggle pane zoom (maximize / restore) |
| `Leader` + `x` | Close current pane (with confirmation) |

### Tabs

| Linux / Windows | macOS | Action |
| :--- | :--- | :--- |
| `Ctrl + Shift + T` or `Leader` + `c` | `Cmd + T` or `Leader` + `c` | New tab |
| `Ctrl + Shift + W` | `Cmd + W` | Close tab |
| `Leader` + `n` / `Leader` + `p` | `Leader` + `n` / `Leader` + `p` | Next / Previous tab |
| `Alt + 1` .. `Alt + 9` | `Cmd + 1` .. `Cmd + 9` | Switch to tab 1-9 |
| — | `Cmd + Shift + {` / `}` | Previous / Next tab |

### Clipboard, Search & Navigation

| Shortcut | Action |
| :--- | :--- |
| `Ctrl + Shift + C` / `Cmd + C` | Copy to clipboard |
| `Ctrl + Shift + V` / `Cmd + V` or `Right-Click` | Paste from clipboard |
| `Leader` + `[` | Enter Copy Mode (navigate scrollback with Vim keys) |
| `Leader` + `/` | Search in scrollback buffer |
| `Ctrl + Click` / `Cmd + Click` | Open hyperlink at mouse cursor |

### General & Windows

| Shortcut | Action |
| :--- | :--- |
| `Leader` + `Space` | Open Launcher menu (switch shells, WSL distros) |
| `Ctrl + Shift + P` / `Cmd + P` | Command Palette |
| `Alt + Enter` | Toggle Fullscreen |
| `Ctrl + Shift + +` / `-` / `0` | Increase / Decrease / Reset font size |

## Neovim / Vim Configuration & Hotkeys

### Custom Shortcuts

| Mode | Shortcut | Command | Action |
| :--- | :--- | :--- | :--- |
| **Visual** | `Ctrl + C` | `"+y` | Copy selection to system clipboard |
| **Normal** | `Ctrl + V` | `"+p` | Paste from system clipboard after cursor |
| **Insert** | `Ctrl + V` | `<C-r><C-o>+` | Paste from system clipboard with formatting & indentation preserved |

> **Note:** Standard Vim commands (`y` to yank, `p` to paste, `d` to delete) also sync automatically to the system clipboard via `clipboard = "unnamedplus"`.

### Cross-Platform Clipboard Support

The configuration automatically detects the platform and configures native clipboard integration:

- **macOS**: `pbcopy` / `pbpaste`
- **Linux (Wayland / Caelestia)**: `wl-copy` / `wl-paste` (via `wl-clipboard`)
- **Remote SSH Sessions**: Native **OSC 52** ANSI escape sequences (syncs yanks directly back to your local client machine's clipboard over SSH without needing X11/Wayland forwarding)

### Plugin Management & Treesitter Commands

| Command | Description |
| :--- | :--- |
| `:Lazy` | Open the `lazy.nvim` plugin manager dashboard (install, update, clean) |
| `:Lazy update` | Update all plugins |
| `:Lazy sync` | Synchronize installed plugins with `lazy-lock.json` |
| `:TSUpdate` | Update Treesitter syntax highlighting parsers |
| `:TSInstall <lang>` | Install Treesitter parser for a specific language (e.g. `:TSInstall rust`) |

### Key Settings & Defaults

- **Theme**: Tokyo Night (`style = "night"`, italic comments) with matching `lualine` statusline
- **Indentation**: 2 spaces (`tabstop=2`, `shiftwidth=2`, `expandtab=true`)
- **Searching**: Smart case (`ignorecase = true`, `smartcase = true` — case-insensitive unless uppercase letters are used)
- **Context**: 10 lines of vertical context padding preserved when scrolling (`scrolloff = 10`)

## Installation

### Ubuntu

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/jaimexu8/dotfiles/main/install-apt.sh)"
```

### Amazon Linux (2023)

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/jaimexu8/dotfiles/main/install-dnf.sh)"
```

