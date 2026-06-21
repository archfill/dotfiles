#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"
source "$DOTFILES_DIR/bin/lib/uv_installer.sh"

# エラーハンドリングを設定
setup_error_handling

# 設定ファイルを読み込み
load_config

log_info "Starting Linux configuration"

# Get OS info using shared library functions
distro="$(get_os_distribution)"
arch="$(detect_architecture)"

install_common_packages_debian() {
    log_info "Installing base OS packages for Debian/Ubuntu..."

    # Parse command line options
    parse_install_options "$@"

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Debian/Ubuntu base OS packages"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        sudo apt update
        sudo apt install -y \
          python3 \
          wget \
          zsh \
          vim \
          fontconfig \
          curl \
          unzip \
          fcitx5 \
          fcitx5-mozc \
          fcitx5-config-qt
    else
        log_info "[DRY RUN] Would install Debian/Ubuntu base OS packages"
    fi

    # User-space tools and language runtimes are managed by Nix.
}

install_common_packages_arch() {
    log_info "Installing base OS packages for Arch Linux..."

    # Parse command line options
    parse_install_options "$@"

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Arch Linux base OS packages"
        return 0
    fi

    # Official repository packages (installed via pacman)
    local official_packages=(
        wget
        unzip
        curl
        fontconfig
        vim
        zsh
    )

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install official repository packages via pacman
        log_info "Installing ${#official_packages[@]} packages from official repositories..."
        sudo pacman -S --needed --noconfirm "${official_packages[@]}"
    else
        log_info "[DRY RUN] Would install ${#official_packages[@]} Arch Linux base OS packages"
    fi

    # User-space tools and language runtimes are managed by Nix.
}

# Main installation function
main() {
    log_info "Linux Package Installation"
    log_info "=========================="
    
    # Parse command line options
    parse_install_options "$@"
    
    case "${distro}" in
      debian | ubuntu)
        log_info "Detected Debian/Ubuntu"
        install_common_packages_debian "$@"
        if [[ "${arch}" == "x86_64" ]]; then
          log_info "Architecture: x86_64"
        fi
        ;;
      arch)
        log_info "Detected Arch Linux"
        install_common_packages_arch "$@"
        ;;
      *)
        log_warning "Unsupported distribution: ${distro}"
        ;;
    esac
    
    log_success "Linux configuration completed!"
}

# Run main function
main "$@"

log_success "Linux configuration completed."
