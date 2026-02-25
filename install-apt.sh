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

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://deb.nodesource.com/setup_lts.x | $SUDO bash -

$SUDO apt update
$SUDO apt install -y git zsh vim stow ripgrep curl tar ca-certificates build-essential xclip nodejs python3 python3-pip python3-venv

python3 -m pip install --user --break-system-packages pynvim 2>/dev/null || python3 -m pip install --user pynvim

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

