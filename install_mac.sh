#!/bin/sh
brew install deno ghq go coreutils
brew tap homebrew/cask-fonts
brew install font-fira-code font-powerline-symbols font-hackgen font-hackgen-nerd font-hack-nerd-font

# lazygit
echo "lazygit"
LAZYGIT_CONFIG=~/Library/Application\ Support/lazygit/config.yml
unlink $LAZYGIT_CONFIG
rm -f $LAZYGIT_CONFIG
ln -sf ~/dotfiles/.config/lazygit/config.yml $LAZYGIT_CONFIG

# karabiner
echo "karabiner SKK"
KARABINER_SKK=~/.config/karabiner/assets/complex_modifications/aquaskk_iterm2.json
unlink $KARABINER_SKK
rm -f $KARABINER_SKK
ln -s ~/dotfiles/.config/karabiner/assets/complex_modifications/aquaskk_iterm2.json $KARABINER_SKK

# yabai
echo "yabai"
YABAIRC=~/.config/yabai
unlink $YABAIRC
rm -rf $YABAIRC
ln -sf ~/dotfiles/.config/yabai $YABAIRC

# skhd
echo "skhd"
SKHDRC=~/.config/skhd
unlink $SKHDRC
rm -rf $SKHDRC
ln -sf ~/dotfiles/.config/skhd $SKHDRC

# hammerspoon
echo "hammerspoon"
HAMMERSPOON_DIR=~/.hammerspoon
HAMMERSPOON_INIT=$HAMMERSPOON_DIR/init.lua
if [ ! -e $HAMMERSPOON_DIR ]; then
  mkdir -p $HAMMERSPOON_DIR
fi
unlink $HAMMERSPOON_INIT
rm -f $HAMMERSPOON_INIT
ln -s ~/dotfiles/hammerspoon/init.lua $HAMMERSPOON_INIT

# stackline - yabai
git clone https://github.com/AdamWagner/stackline.git ~/.hammerspoon/stackline

git config --global ghq.root '~/git'
