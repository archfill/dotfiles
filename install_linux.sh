#!/bin/bash -eu

echo "Linux config start"

declare -a info=($(./get_os_info.sh))

case ${info[0]} in
ubuntu)
  echo "ubuntu"
    
  sudo apt update
  sudo apt install -y python python-pip wget

  pip install requests

  if [[ ${info[1]} == "x86_64" ]]; then
      echo x86_64
  fi
  ;;
arch)
  echo "arch"
  sudo pacman -Sy
  sudo pacman -S python2 python2-pip wget

  pip2 install requests
  ;;
*)
    echo "unsupported"
    ;;
esac

# terminator
rm -rf ~/.config/terminator
ln -sf ~/dotfiles/terminator ~/.config/terminator
## terminator-themes
rm -rf ~/.config/terminator/plugins
mkdir -p ~/.config/terminator/plugins
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py"

echo "Linux config end"
