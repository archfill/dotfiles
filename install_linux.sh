#!/bin/sh

echo "Linux config start"

# terminator
rm -rf ~/.config/terminator
ln -sf ~/dotfiles/terminator ~/.config/terminator
## terminator-themes
sudo apt update
sudo apt install -y python python-pip wget
pip install requests
rm -rf ~/.config/terminator/plugins
mkdir -p ~/.config/terminator/plugins
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py"

echo "Linux config end"
