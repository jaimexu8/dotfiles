# My Dotfiles

Configuration files for Amazon Linux (EC2), Arch Linux, macOs, and data.cs.purdue.edu.

## Structure

- **git/** - Global Git config & ignore files
- **nvim/** - Neovim (init.lua + lazy-lock.json)
- **vim/** - Vim config (.vimrc)
- **caelestia/** - Caelestia shell config
- **fish/** - Fish config (Arch Linux)
- **zsh/** - Zsh config (Amazon Linux, macOs, data.cs.purdue.edu)

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/jaimexu8/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Backup existing configs

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.vimrc ~/.vimrc.bak
mv ~/.gitconfig ~/.gitconfig.bak
mv ~/.config/fish ~/.config/fish.bak 
mv ~/.zshrc ~/.zshrc.bak
```

### 3. Install

#### Amazon Linux 2023 (EC2)

Amazon Linux 2023 requires manual package installation for Neovim (built from release), Zsh, and Ripgrep (via SPAL repository).

**1. Install Core Dependencies & SPAL Repo**
```bash
sudo dnf update -y
sudo dnf install -y git zsh vim util-linux-user spal-release
sudo dnf makecache
sudo dnf install -y ripgrep
```

**2. Install Neovim**
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
```

**3. Link Configs (Manual Symlinks)**
```bash
mkdir -p ~/.config
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/git/.gitignore_global ~/.gitignore_global
ln -sf ~/dotfiles/vim/.vimrc ~/.vimrc
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/nvim/.config/nvim ~/.config/nvim
```

**4. Set Zsh as Default Shell**
```bash
sudo chsh -s $(which zsh) ec2-user
```
*(Log out and back in to apply the shell change, then launch `nvim` to let lazy.nvim install plugins).*

#### Arch Linux (Fish)

```bash
stow git nvim vim caelestia fish
```

#### macOS (Zsh)

```bash
stow git nvim vim zsh
```

#### data.cs.purdue.edu (Bash)

```bash
ln -s ~/dotfiles/vim/.vimrc ~/.vimrc
mkdir -p ~/.config
ln -s ~/dotfiles/nvim/.config/nvim ~/.config/nvim
echo "source ~/dotfiles/zsh/.zshrc" >> ~/.zshrc
```

