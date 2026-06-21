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

        # Download and install deb package
        local temp_dir
        temp_dir=$(mktemp -d)
        local deb_package="tenv_v${version}_${arch}.deb"
        local url="https://github.com/tofuutils/tenv/releases/download/v${version}/${deb_package}"

        if curl -sL "$url" -o "${temp_dir}/${deb_package}"; then
            sudo dpkg -i "${temp_dir}/${deb_package}"
            rm -rf "${temp_dir}"

            # Verify installation
            if command -v tenv >/dev/null 2>&1; then
                log_success "tenv installed successfully: $(tenv --version 2>/dev/null | head -1 || echo "v${version}")"
            else
                log_error "tenv installation failed"
                return 1
            fi
        else
            log_error "Failed to download tenv deb package"
            rm -rf "${temp_dir}"
            return 1
        fi
    else
        log_info "[DRY RUN] Would download and install tenv binary"
    fi

    return 0
}

# Install fastfetch for Debian/Ubuntu (not in official repos)
install_fastfetch_debian() {
    log_info "Installing fastfetch for Debian/Ubuntu..."

    # Parse command line options
    parse_install_options "$@"

    # Check if fastfetch should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v fastfetch >/dev/null 2>&1; then
        log_skip_reason "fastfetch" "Already installed: $(fastfetch --version 2>/dev/null | head -1 || echo 'version unknown')"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install fastfetch"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Detect architecture
        local arch
        case "$(uname -m)" in
            x86_64)  arch="amd64" ;;
            aarch64) arch="aarch64" ;;
            *)
                log_error "Unsupported architecture: $(uname -m)"
                return 1
                ;;
        esac

        # Get latest version from GitHub API
        local version
        version=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

        if [[ -z "$version" ]]; then
            log_error "Failed to get latest fastfetch version"
            return 1
        fi

        log_info "Installing fastfetch ${version} for ${arch}..."

        # Download and install deb package
        local temp_dir
        temp_dir=$(mktemp -d)
        local deb_package="fastfetch-linux-${arch}.deb"
        local url="https://github.com/fastfetch-cli/fastfetch/releases/download/${version}/${deb_package}"

        if curl -sL "$url" -o "${temp_dir}/${deb_package}"; then
            sudo dpkg -i "${temp_dir}/${deb_package}"
            rm -rf "${temp_dir}"

            # Verify installation
            if command -v fastfetch >/dev/null 2>&1; then
                log_success "fastfetch installed successfully: $(fastfetch --version 2>/dev/null | head -1 || echo "${version}")"
            else
                log_error "fastfetch installation failed"
                return 1
            fi
        else
            log_error "Failed to download fastfetch deb package"
            rm -rf "${temp_dir}"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install fastfetch from GitHub releases"
    fi

    return 0
}

install_yazi_debian() {
    log_info "Installing yazi for Debian/Ubuntu..."

    # Parse command line options
    parse_install_options "$@"

    # Check if yazi should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v yazi >/dev/null 2>&1; then
        log_skip_reason "yazi" "Already installed: $(yazi --version 2>/dev/null || echo 'version unknown')"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install yazi"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Detect architecture
        local arch
        case "$(uname -m)" in
            x86_64)  arch="x86_64-unknown-linux-musl" ;;
            aarch64) arch="aarch64-unknown-linux-musl" ;;
            armv7l)  arch="armv7-unknown-linux-musleabihf" ;;
            *)
                log_error "Unsupported architecture: $(uname -m)"
                return 1
                ;;
        esac

        # Get latest version from GitHub API
        local version
        version=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

        if [[ -z "$version" ]]; then
            log_error "Failed to get latest yazi version"
            return 1
        fi

        log_info "Installing yazi v${version} for ${arch}..."

        # Download and install deb package
        local temp_dir
        temp_dir=$(mktemp -d)
        local deb_package="yazi-${arch}.deb"
        local url="https://github.com/sxyazi/yazi/releases/download/v${version}/${deb_package}"

        if curl -sL "$url" -o "${temp_dir}/${deb_package}"; then
            sudo dpkg -i "${temp_dir}/${deb_package}"
            rm -rf "${temp_dir}"

            # Verify installation
            if command -v yazi >/dev/null 2>&1; then
                log_success "yazi installed successfully: $(yazi --version 2>/dev/null || echo "v${version}")"
            else
                log_error "yazi installation failed"
                return 1
            fi
        else
            log_error "Failed to download yazi deb package"
            rm -rf "${temp_dir}"
            return 1
        fi
    else
        log_info "[DRY RUN] Would download and install yazi binary"
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
          wget \
          less \
          zsh \
          tmux \
          vim \
          fzf \
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
          sqlite3 \
          libsqlite3-dev \
          ffmpegthumbnailer \
          poppler-utils \
          fd-find \
          imagemagick \
          ffmpeg \
          fcitx5 \
          fcitx5-mozc \
          fcitx5-config-qt
    else
        log_info "[DRY RUN] Would install Debian/Ubuntu packages"
    fi

    # Install mise (via official APT repository)
    install_mise_debian "$@"

    # Install tenv (via binary installation)
    install_tenv_debian "$@"

    # Install yazi (via binary installation)
    install_yazi_debian "$@"

    # Install fastfetch (via GitHub releases, not in Ubuntu repos)
    install_fastfetch_debian "$@"

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
        bun
        ripgrep
        git-delta
        wget
        unzip
        p7zip
        curl
        fontconfig
        less
        mpv
        vim
        zsh
        tmux
        fzf
        lazygit
        bottom
        zoxide
        bat
        jq
        wl-clipboard
        cliphist
        sqlite
        yazi
        ffmpegthumbnailer
        poppler
        fd
        imagemagick
        deno
        fastfetch
        matugen
    )

    # AUR-only packages (installed via yay)
    local aur_packages=(
        ghostty
        tenv-bin
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
