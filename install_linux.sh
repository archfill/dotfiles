#!/bin/bash -eu

echo "Linux config start"

declare -a info=($(./get_os_info.sh))

case ${info[0]} in
ubuntu)
  echo "ubuntu"
    
  sudo apt update
  sudo apt install -y python \
    python-pip \
    wget \
    w3m \
    neomutt \
    silversearcher-ag

  pip install requests

  if [[ ${info[1]} == "x86_64" ]]; then
      echo x86_64
  fi
  ;;
arch)
  echo "arch"
  sudo pacman -Sy
  sudo pacman -S python2 \
    python2-pip \
    wget \

  yay -S neovim \
    neomutt \
    w3m \
    mpv

  sudo pip2 install requests

  sudo pip3 install mps-youtube
  ;;
*)
    echo "unsupported"
    ;;
esac

# terminator
rm -rf ~/.config/terminator
ln -sf ~/dotfiles/.config/terminator ~/.config/terminator
## terminator-themes
rm -rf ~/.config/terminator/plugins
mkdir -p ~/.config/terminator/plugins
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py"

echo "Linux config end"
