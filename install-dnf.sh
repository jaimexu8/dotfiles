#!/bin/bash

SUDO=''
if [ "$(id -u)" -ne 0 ]; then
  SUDO='sudo'
fi

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  NVIM_RELEASE="nvim-linux-x86_64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  NVIM_RELEASE="nvim-linux-arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

$SUDO dnf update -y
$SUDO dnf install -y spal-release
$SUDO dnf makecache
$SUDO dnf groupinstall -y "Development Tools"
$SUDO dnf install -y git zsh vim util-linux-user stow ripgrep curl tar gzip wl-clipboard nodejs python3 python3-pip

$SUDO npm install -g neovim tree-sitter-cli
python3 -m pip install --user pynvim

curl -LO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_RELEASE}.tar.gz"
$SUDO tar -C /opt -xzf "${NVIM_RELEASE}.tar.gz"
$SUDO ln -sf "/opt/${NVIM_RELEASE}/bin/nvim" /usr/local/bin/nvim
rm "${NVIM_RELEASE}.tar.gz"

if [ ! -d "$HOME/dotfiles" ]; then
  git clone https://github.com/jaimexu8/dotfiles.git ~/dotfiles
fi

cd ~/dotfiles

mkdir -p ~/.config
stow --adopt git nvim vim zsh
git restore .

$SUDO chsh -s $(which zsh) $(whoami)
exec zsh

