#!/bin/bash

echo 'setting neovim'
echo 'link'
NEOVIM_DIR=~/.config/nvim
ln -snf ~/dotfiles/nvim/ $NEOVIM_DIR

echo 'install packer.nvim'
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
