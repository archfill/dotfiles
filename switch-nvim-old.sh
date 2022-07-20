#!/bin/bash

echo "switch init.vim"
NEOVIM_DIR=~/.config/nvim
unlink $NEOVIM_DIR
rm -r $NEOVIM_DIR
ln -s ~/dotfiles/nvim-old $NEOVIM_DIR
