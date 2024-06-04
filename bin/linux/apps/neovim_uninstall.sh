#!/usr/bin/env bash

cd ~/build/neovim
sudo cmake --build build/ --target uninstall

rm -rf ~/.local/bin/nvim
rm -rf ~/.local/lib/nvim
