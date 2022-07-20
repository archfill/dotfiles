#!/bin/bash

echo "switch init.lua"
NEOVIM_DIR=~/.config/nvim
unlink $NEOVIM_DIR
rm -r $NEOVIM_DIR
ln -s ~/dotfiles/nvim $NEOVIM_DIR
