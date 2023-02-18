#!/usr/bin/env bash

set -ue

case `uname -m` in
'x86_64')
  function neovim_nightly() {
    mkdir -p ~/.local/
    curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz | tar zx --strip-components 1 -C ~/.local/
  }

  neovim_nightly
  ;;
'arm64' | 'arm')
  declare -a info=($(./get_os_info.sh))

  case ${info[0]} in
  debian | ubuntu)
    echo "debian or ubuntu"

    sudo apt update
    sudo apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen libsqlite3-dev

    if [[ ${info[1]} == "x86_64" ]]; then
        echo x86_64
    fi
    ;;
  "arch" )
    echo "arch"

    sudo pacman -S base-devel cmake unzip ninja tree-sitter curl

    ;;
  *)
    echo "unsupported"
    ;;
  esac

  mkdir ~/build
  cd ~/build

  if [ -e `./neovim` ]; then
    rm -rf ./neovim
  fi

  git clone https://github.com/neovim/neovim
  cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  ;;
*)
  echo "unsupported"
  ;;
esac

