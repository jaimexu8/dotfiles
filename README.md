# Dotfiles

## Structure

- caelestia/ - Caelestia shell config
- fish/ - Fish config
- git/ - Global Git config & ignore files
- nvim/ - Neovim (init.lua + lazy-lock.json)
- vim/ - Vim config (.vimrc)
- zsh/ - Zsh config

## Installation

### Ubuntu

```bash
# Define sudo only if not running as root
SUDO=''
if [ "$(id -u)" -ne 0 ]; then
  SUDO='sudo'
fi

# Update system and install prerequisites
$SUDO apt update
$SUDO apt install -y git zsh vim stow ripgrep curl tar ca-certificates

# Install latest stable Neovim via binary
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
$SUDO tar -C /opt -xzf nvim-linux-x86_64.tar.gz
$SUDO ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz

# Clone dotfiles repository
git clone https://github.com/jaimexu8/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Stow configurations 
mkdir -p ~/.config
stow --adopt git nvim vim zsh
git restore .

# Change default shell to Zsh
$SUDO chsh -s $(which zsh) $(whoami)

# Start Zsh
exec zsh
```

### Amazon Linux 2023

```bash
# Define sudo only if not running as root
SUDO=''
if [ "$(id -u)" -ne 0 ]; then
  SUDO='sudo'
fi

# Update system and install prerequisites
$SUDO dnf update -y
$SUDO dnf install -y spal-release
$SUDO dnf makecache
$SUDO dnf install -y git zsh vim util-linux-user stow ripgrep curl tar gzip

# Install latest stable Neovim via binary
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
$SUDO tar -C /opt -xzf nvim-linux-x86_64.tar.gz
$SUDO ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz

# Clone dotfiles repository
git clone https://github.com/jaimexu8/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Stow configurations
mkdir -p ~/.config
stow --adopt git nvim vim zsh
git restore .

# Change default shell to Zsh
$SUDO chsh -s $(which zsh) $(whoami)

# Start Zsh
exec zsh
```

