#!/usr/bin/env bash

function link() {
  if [ $# == 1 ]; then
    DOT_PATH="${HOME}/dotfiles/$1"
    TARGET_PATH="${HOME}/$1"
  elif [ $# == 2 ]; then
    DOT_PATH="${HOME}/$1"
    TARGET_PATH="${HOME}/$2"
  else
    echo "argument error."
    return
  fi

  if [ -d $TARGET_PATH ]; then
    rm -rf $TARGET_PATH
  fi
  ln -snf $DOT_PATH $TARGET_PATH
}

# lazygit
link "dotfiles/.config/lazygit/config.yml" "Library/Application\ Support/lazygit/config.yml"

# karabiner
link ".config/karabiner/assets/complex_modifications/aquaskk_iterm2.json"

# yabai
link ".config/yabai"

# skhd
link ".config/skhd"

# hammerspoon
HAMMERSPOON_DIR=${HOME}/.hammerspoon
if [ ! -e $HAMMERSPOON_DIR ]; then
  mkdir -p $HAMMERSPOON_DIR
fi
link ".hammerspoon/init.lua"
