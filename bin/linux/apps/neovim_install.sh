#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/common.sh"
source "${SCRIPT_DIR}/../../lib/config_loader.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting Neovim installation"

# 設定を読み込み
load_config

case "$(detect_architecture)" in
'x86_64')
  install_neovim_nightly_x64() {
    log_info "Installing Neovim nightly for x86_64"
    mkdir -p ~/.local/
    curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz | tar zx --strip-components 1 -C ~/.local/
    log_success "Neovim nightly installation completed"
  }

  install_neovim_nightly_x64
  ;;
'arm64' | 'arm' | 'aarch64')
  install_neovim_arm() {
    log_info "Installing Neovim for ARM architecture"
    
    local distro arch
    read -r distro arch <<< "$(get_os_info)"

    case "$distro" in
    debian | ubuntu)
      log_info "Installing build dependencies for Debian/Ubuntu"
      sudo apt update
      sudo apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen libsqlite3-dev
      ;;
    arch)
      log_info "Installing build dependencies for Arch Linux"
      sudo pacman -S base-devel cmake unzip ninja tree-sitter curl
      ;;
    *)
      log_error "Unsupported distribution: $distro"
      return 1
      ;;
    esac

    # Build directory setup
    local build_dir="${LINUX_BUILD_DIR:-$HOME/build}"
    log_info "Setting up build directory: $build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"

    # Clean existing neovim directory
    if [[ -d "./neovim" ]]; then
      log_info "Removing existing neovim directory"
      rm -rf ./neovim
    fi

    # Clone and build Neovim
    log_info "Cloning Neovim repository"
    git clone https://github.com/neovim/neovim
    
    log_info "Building Neovim (this may take a while)"
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
    
    log_info "Installing Neovim"
    sudo make install
    
    log_success "Neovim ARM installation completed"
  }

  install_neovim_arm
  ;;
*)
  log_error "Unsupported architecture: $(detect_architecture)"
  exit 1
  ;;
esac

log_success "Neovim installation process completed"

