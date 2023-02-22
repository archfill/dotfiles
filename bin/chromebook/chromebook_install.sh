#!/bin/sh

# ./install.sh

# alacritty
echo "alacritty for chromebook"
ALACRITTY_DIR=~/.config/alacritty
ALACRITTY_FILE=$ALACRITTY_DIR/alacritty.yml
unlink $ALACRITTY_DIR
rm -rf $ALACRITTY_DIR
mkdir -p $ALACRITTY_DIR
ln -sf ~/dotfiles/.config/alacritty/alacritty-chromebook.yml $ALACRITTY_FILE

exit 0
