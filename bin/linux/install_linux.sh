#!/usr/bin/env bash

set -euo pipefail
trap 'echo "[Error] Command \"$BASH_COMMAND\" failed."; exit 1' ERR

echo "[Start] Linux configuration"

# Get OS info
read -r distro arch <<< "$("${HOME}/dotfiles/bin/get_os_info.sh")"

install_common_packages_debian() {
    echo "[Info] Installing packages for Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y \
      python3 \
      python3-pip \
      wget \
      w3m \
      neomutt \
      zsh \
      tmux \
      vim \
      silversearcher-ag \
      ripgrep \
      fontconfig

    pip3 install --user requests
}

install_common_packages_arch() {
    echo "[Info] Installing packages for Arch Linux..."
    sudo pacman -Suy --needed git base-devel --noconfirm

    tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "${tempdir}/yay"
    pushd "${tempdir}/yay" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "${tempdir}"

    yay -Syu --noconfirm \
      ripgrep \
      wget \
      unzip \
      curl \
      fontconfig \
      neomutt \
      w3m \
      mpv \
      vim \
      zsh \
      tmux \
      lazygit \
      luarocks \
      lua51 \
      bottom \
      the_silver_searcher

    pip install --user mps-youtube
}

case "${distro}" in
  debian | ubuntu)
    echo "[Detected] Debian/Ubuntu"
    install_common_packages_debian
    if [[ "${arch}" == "x86_64" ]]; then
      echo "[Info] Architecture: x86_64"
    fi
    ;;
  arch)
    echo "[Detected] Arch Linux"
    install_common_packages_arch
    ;;
  *)
    echo "[Warning] Unsupported distribution: ${distro}"
    ;;
esac

echo "[Success] Linux configuration completed."
