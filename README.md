# My Dotfiles

Configuration files for Arch Linux, macOS, and data.cs.purdue.edu

## Structure

- **git/** - Global Git config & ignore files
- **nvim/** - Neovim (init.lua + lazy-lock.json)
- **vim/** - Vim config (.vimrc)
- **caelestia/** - Caelestia shell config
- **fish/** - Fish config (Arch Linux)
- **zsh/** - Zsh config (macOS)
- **bash/** - Bash config (data.cs.purdue.edu)

## Installation

1. Clone the repository

```bash
git clone https://github.com/jaimexu8/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Backup existing configs

### Example backups

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.vimrc ~/.vimrc.bak
mv ~/.gitconfig ~/.gitconfig.bak
mv ~/.config/fish ~/.config/fish.bak 
mv ~/.zshrc ~/.zshrc.bak
```

3. Install

### Arch Linux (Fish)

```bash
stow git nvim vim caelestia fish
```

### macOS (Zsh)

```bash
stow git nvim vim zsh
```

### data.cs.purdue.edu

```bash
# Link vim
ln -s ~/dotfiles/vim/.vimrc ~/.vimrc

# Link Neovim
mkdir -p ~/.config
ln -s ~/dotfiles/nvim/.config/nvim ~/.config/nvim

# Source Bash config
echo "source ~/dotfiles/bash/.bashrc" >> ~/.bashrc
```

