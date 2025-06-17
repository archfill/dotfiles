#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/uv_installer.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting Linux configuration"

# Get OS info using shared library functions
distro="$(get_os_distribution)"
arch="$(detect_architecture)"

install_common_packages_debian() {
    log_info "Installing packages for Debian/Ubuntu..."
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
      fontconfig \
      curl

    # Install uv using common library
    install_uv
}

install_common_packages_arch() {
    log_info "Installing packages for Arch Linux..."
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

    # Install uv using common library
    install_uv
}

case "${distro}" in
  debian | ubuntu)
    log_info "Detected Debian/Ubuntu"
    install_common_packages_debian
    if [[ "${arch}" == "x86_64" ]]; then
      log_info "Architecture: x86_64"
    fi
    ;;
  arch)
    log_info "Detected Arch Linux"
    install_common_packages_arch
    ;;
  *)
    log_warning "Unsupported distribution: ${distro}"
    ;;
esac

log_success "Linux configuration completed."
