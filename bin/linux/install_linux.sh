#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
    log_info "Installing packages for Debian/Ubuntu..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Debian/Ubuntu packages"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
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
          fzf \
          fontconfig \
          curl \
          unzip \
          p7zip-full
    else
        log_info "[DRY RUN] Would install Debian/Ubuntu packages"
    fi

    # Install uv using common library
    install_uv "$@"
}

# Install yay (AUR helper) with skip logic
install_yay_arch() {
    log_info "Installing yay (AUR helper)..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if yay should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v yay >/dev/null 2>&1; then
        log_skip_reason "yay" "Already installed: $(yay --version 2>/dev/null | head -1 || echo 'version unknown')"
        return 0
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install yay (AUR helper)"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Install base-devel if needed
        sudo pacman -Suy --needed git base-devel --noconfirm
        
        # Install yay from AUR
        local tempdir
        tempdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "${tempdir}/yay"
        pushd "${tempdir}/yay" >/dev/null
        makepkg -si --noconfirm
        popd >/dev/null
        rm -rf "${tempdir}"
        
        # Verify yay installation
        if command -v yay >/dev/null 2>&1; then
            log_success "yay installed successfully: $(yay --version | head -1)"
        else
            log_error "yay installation failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install yay from AUR"
    fi
    
    return 0
}

install_common_packages_arch() {
    log_info "Installing packages for Arch Linux..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Install yay first (with skip logic)
    install_yay_arch "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Arch Linux packages"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Install packages via yay (if available) or pacman
        if command -v yay >/dev/null 2>&1; then
            yay -Syu --noconfirm \
              ripgrep \
              fzf \
              wget \
              unzip \
              p7zip \
              curl \
              fontconfig \
              neomutt \
              w3m \
              mpv \
              vim \
              zsh \
              tmux \
              lazygit \
              gitu \
              luarocks \
              lua51 \
              bottom \
              the_silver_searcher
        else
            log_warning "yay not available, using pacman for basic packages"
            sudo pacman -Syu --noconfirm \
              ripgrep \
              fzf \
              wget \
              unzip \
              p7zip \
              curl \
              fontconfig \
              vim \
              zsh \
              tmux \
              lazygit \
              gitu
        fi
    else
        log_info "[DRY RUN] Would install Arch Linux packages via yay/pacman"
    fi

    # Install uv using common library
    install_uv "$@"
}

# Install bun JavaScript runtime
install_bun() {
    log_info "Installing bun JavaScript runtime..."
    
    # Check if already installed
    if command -v bun >/dev/null 2>&1; then
        local current_version=$(bun --version 2>/dev/null || echo "unknown")
        log_info "bun already installed: $current_version"
        return 0
    fi
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install bun"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Install bun using official install script
        if command -v curl >/dev/null 2>&1; then
            log_info "Installing bun via official install script..."
            curl -fsSL https://bun.sh/install | bash
            
            # Add to current session PATH
            if [[ -d "$HOME/.bun/bin" ]]; then
                export PATH="$HOME/.bun/bin:$PATH"
                log_success "bun installed successfully"
                log_info "bun version: $(bun --version 2>/dev/null || echo 'unknown')"
                log_info "Add to your shell profile: export PATH=\"\$HOME/.bun/bin:\$PATH\""
            else
                log_error "bun installation failed"
                return 1
            fi
        else
            log_error "curl not found. Please install curl first."
            return 1
        fi
    else
        log_info "[DRY RUN] Would install bun via official script"
    fi
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
    
    # Install bun for all distributions
    install_bun "$@"
    
    log_success "Linux configuration completed!"
    
    if [[ "${distro}" == "arch" ]]; then
        log_info ""
        log_info "Available yay commands:"
        log_info "  yay -S <package>       # Install package from official repos or AUR"
        log_info "  yay -Syu               # Update all packages"
        log_info "  yay -Ss <search>       # Search packages"
        log_info "  yay -Qi <package>      # Show package info"
        log_info ""
        log_info "Note: yay provides access to AUR (Arch User Repository) packages"
    fi
}

# Run main function
main "$@"

log_success "Linux configuration completed."
