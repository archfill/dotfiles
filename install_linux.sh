#!/bin/bash -eu

echo "Linux config start"

declare -a info=($(./get_os_info.sh))

case ${info[0]} in
debian | ubuntu)
  echo "debian or ubuntu"
    
  sudo apt update
  sudo apt install -y python3 \
    python3-pip \
    wget \
    w3m \
    neomutt \
    zsh \
    tmux \
    vim \
    silversearcher-ag

  pip install requests

  if [[ ${info[1]} == "x86_64" ]]; then
      echo x86_64
  fi
  ;;
"arch" )
  echo "arch"
  sudo pacman -Suy python2 \
    python2-pip \
    wget \
    unzip

  yay -S neovim \
    neomutt \
    w3m \
    mpv \
    vim \
    zsh \
    tmux \
    the_silver_searcher

  sudo pip2 install requests

  sudo pip3 install mps-youtube
  ;;
*)
    echo "unsupported"
    ;;
esac

# neovim
echo 'install neovim.'
bash ./install_neovim.sh
echo 'finish neovim.'

# terminator
#rm -rf ~/.config/terminator
#ln -sf ~/dotfiles/.config/terminator ~/.config/terminator
## terminator-themes
#rm -rf ~/.config/terminator/plugins
#mkdir -p ~/.config/terminator/plugins
#wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py"

echo "Linux config end"
