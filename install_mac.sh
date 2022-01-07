#!/bin/sh
brew install neovim deno ghq go
brew tap homebrew/cask-fonts
brew install font-fira-code font-powerline-symbols font-hackgen font-hackgen-nerd

git config --global ghq.root '~/git'
