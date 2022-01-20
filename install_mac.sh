#!/bin/sh
brew install neovim deno ghq go
brew tap homebrew/cask-fonts
brew install font-fira-code font-powerline-symbols font-hackgen font-hackgen-nerd

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

git config --global ghq.root '~/git'
