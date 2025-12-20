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

# Install tenv for Debian/Ubuntu (binary installation)
install_tenv_debian() {
    log_info "Installing tenv for Debian/Ubuntu..."

    # Parse command line options
    parse_install_options "$@"

    # Check if tenv should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v tenv >/dev/null 2>&1; then
        log_skip_reason "tenv" "Already installed: $(tenv --version 2>/dev/null | head -1 || echo 'version unknown')"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install tenv"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Detect architecture
        local arch
        case "$(uname -m)" in
            x86_64)  arch="amd64" ;;
            aarch64) arch="arm64" ;;
            armv7l)  arch="armv7" ;;
            *)
                log_error "Unsupported architecture: $(uname -m)"
                return 1
                ;;
        esac

        # Get latest version from GitHub API
        local version
        version=$(curl -s https://api.github.com/repos/tofuutils/tenv/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

        if [[ -z "$version" ]]; then
            log_error "Failed to get latest tenv version"
            return 1
        fi

        log_info "Installing tenv v${version} for ${arch}..."

        # Create local bin directory
        mkdir -p "$HOME/.local/bin"

        # Download and extract
        local temp_dir
        temp_dir=$(mktemp -d)
        local tarball="tenv_v${version}_Linux_${arch}.tar.gz"
        local url="https://github.com/tofuutils/tenv/releases/download/v${version}/${tarball}"

        if curl -sL "$url" -o "${temp_dir}/${tarball}"; then
            tar -xzf "${temp_dir}/${tarball}" -C "${temp_dir}"
            # Install binaries
            for bin in tenv terraform tofu terragrunt terramate atmos; do
                if [[ -f "${temp_dir}/${bin}" ]]; then
                    install -m 755 "${temp_dir}/${bin}" "$HOME/.local/bin/${bin}"
                fi
            done
            rm -rf "${temp_dir}"

            # Verify installation
            if command -v tenv >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/tenv" ]]; then
                log_success "tenv installed successfully: $("$HOME/.local/bin/tenv" --version 2>/dev/null | head -1 || echo "v${version}")"
            else
                log_warning "tenv installed to ~/.local/bin - ensure it's in your PATH"
            fi
        else
            log_error "Failed to download tenv"
            rm -rf "${temp_dir}"
            return 1
        fi
    else
        log_info "[DRY RUN] Would download and install tenv binary"
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
          wl-clipboard \
          xsel \
          xclip \
          sqlite3 \
          libsqlite3-dev \
          yazi \
          ffmpegthumbnailer \
          poppler-utils \
          fd-find \
          imagemagick \
          fastfetch
    else
        log_info "[DRY RUN] Would install Debian/Ubuntu packages"
    fi

    # Install mise (via official APT repository)
    install_mise_debian "$@"

    # Install tenv (via binary installation)
    install_tenv_debian "$@"

    # Note: uv is now installed via bin/apps/languages/python.sh
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
        tenv
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
        wl-clipboard
        xsel
        xclip
        sqlite
        yazi
        ffmpegthumbnailer
        poppler
        fd
        imagemagick
        deno
        fastfetch
    )

    # AUR-only packages (installed via yay)
    local aur_packages=(
        urlscan
        khard
        bun-bin
        ghostty
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
