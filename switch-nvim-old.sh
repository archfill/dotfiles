#!/bin/bash

echo "switch init.vim"
NEOVIM_DIR=~/.config/nvim
ln -snf ~/dotfiles/nvim-old $NEOVIM_DIR
