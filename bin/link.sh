#!/usr/bin/env bash

function link() {
  target_path="~/$1"
  dot_path="~/dotfiles/$1"

  if [ -d $target_path ]; then
    rm -rf $target_path
  fi
  ln -snf $dot_path $target_path
}

# neovim
link ".config/nvim"

