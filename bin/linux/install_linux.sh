#!/usr/bin/env bash

echo "Linux config start"

declare -a info=($(${HOME}/dotfiles/bin/get_os_info.sh))

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
    silversearcher-ag \
    fontconfig

  pip install requests

  if [[ ${info[1]} == "x86_64" ]]; then
      echo x86_64
  fi
  ;;
"arch" )
  echo "arch"
  sudo pacman -Suy --noconfirm \
    ripgrep \
    wget \
    unzip

  pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

  yay -Syu --noconfirm \
    neomutt \
    w3m \
    mpv \
    vim \
    zsh \
    tmux \
    lazygit \
    the_silver_searcher

  sudo pip2 install requests

  sudo pip3 install mps-youtube
  ;;
*)
    echo "unsupported"
    ;;
esac

echo "Linux config end"
