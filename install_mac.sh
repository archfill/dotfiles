#!/bin/sh
brew install neovim deno ghq go
brew tap homebrew/cask-fonts
brew install font-fira-code font-powerline-symbols

git config --global ghq.root '~/git'
