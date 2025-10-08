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

# Install mise for Debian/Ubuntu
install_mise_debian() {
    log_info "Installing mise for Debian/Ubuntu..."

    # Parse command line options
    parse_install_options "$@"

    # Check if mise should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v mise >/dev/null 2>&1; then
        log_skip_reason "mise" "Already installed: $(mise --version 2>/dev/null || echo 'version unknown')"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install mise"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install prerequisites
        sudo apt update -y
        sudo apt install -y gpg sudo wget curl

        # Add mise repository
        sudo install -dm 755 /etc/apt/keyrings
        wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list

        # Install mise
        sudo apt update
        sudo apt install -y mise

        # Verify installation
        if command -v mise >/dev/null 2>&1; then
            log_success "mise installed successfully: $(mise --version)"
        else
            log_error "mise installation failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would add mise repository and install mise"
    fi

    return 0
}

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
          aerc \
          urlscan \
          khard \
          notmuch \
          isync \
          msmtp \
          less \
          zsh \
          tmux \
          vim \
          fzf \
          silversearcher-ag \
          ripgrep \
          git-delta \
          fontconfig \
          curl \
          unzip \
          p7zip-full \
          zoxide \
          bat \
          jq \
          xsel \
          xclip \
          sqlite3 \
          libsqlite3-dev \
          yazi \
          ffmpegthumbnailer \
          poppler-utils \
          fd-find \
          imagemagick
    else
        log_info "[DRY RUN] Would install Debian/Ubuntu packages"
    fi

    # Note: uv is now installed via bin/apps/languages/python.sh
    # mise is installed in this script for Debian/Ubuntu (via official APT repository)
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

    # Official repository packages (installed via pacman)
    local official_packages=(
        mise
        ripgrep
        git-delta
        wget
        unzip
        p7zip
        curl
        fontconfig
        neomutt
        aerc
        w3m
        notmuch
        isync
        msmtp
        less
        mpv
        vim
        zsh
        tmux
        fzf
        lazygit
        luarocks
        lua51
        bottom
        the_silver_searcher
        zoxide
        bat
        jq
        xsel
        xclip
        sqlite
        yazi
        ffmpegthumbnailer
        poppler
        fd
        imagemagick
        deno
    )

    # AUR-only packages (installed via yay)
    local aur_packages=(
        urlscan
        khard
    )

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install official repository packages via pacman
        log_info "Installing ${#official_packages[@]} packages from official repositories..."
        sudo pacman -S --needed --noconfirm "${official_packages[@]}"

        # Install AUR packages via yay (if available)
        if command -v yay >/dev/null 2>&1; then
            log_info "Installing ${#aur_packages[@]} packages from AUR..."
            yay -S --needed --noconfirm "${aur_packages[@]}"
        else
            log_warning "yay not available. AUR packages skipped: ${aur_packages[*]}"
            log_info "Install yay to enable AUR package installation"
        fi
    else
        log_info "[DRY RUN] Would install ${#official_packages[@]} official packages via pacman"
        log_info "[DRY RUN] Would install ${#aur_packages[@]} AUR packages via yay"
    fi

    # Note: uv is installed via bin/apps/languages/python.sh
    # mise is installed in this script (via pacman for Arch Linux)
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
