#!/usr/bin/env bash

# eza (modern ls replacement) installation and configuration management script
# This script installs eza across different platforms

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting eza (modern ls replacement) setup..."

# Check eza installation
check_eza_environment() {
    log_info "Checking eza environment..."

    if ! is_command_available "eza" "--version"; then
        log_info "eza not available"
        return 1
    fi

    log_success "eza environment checks passed"
    return 0
}

# Check eza version requirements
check_eza_version_requirements() {
    local required_version="${EZA_VERSION:-0.10.0}"

    log_info "Checking eza version requirements (>= $required_version)..."

    if ! command -v eza >/dev/null 2>&1; then
        log_info "eza command not available"
        return 1
    fi

    # eza version output format: "eza - A modern, maintained replacement for ls"
    # version line: "v0.18.0 [+git]"
    local current_version
    current_version=$(eza --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/^v//')

    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine eza version"
        return 1
    fi

    compare_versions "$current_version" "$required_version"
    local result=$?

    case $result in
        0|2)  # current >= required
            log_success "eza version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "eza version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for eza"
            return 1
            ;;
    esac
}

# Install eza
install_eza() {
    log_info "Installing eza..."

    # Parse command line options
    parse_install_options "$@"

    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install eza"
        return 0
    fi

    local distro="$(get_os_distribution)"
    local os_name="$(uname -s)"

    if [[ "$DRY_RUN" != "true" ]]; then
        case "$os_name" in
            Darwin)
                log_info "Installing eza via Homebrew on macOS..."
                if command -v brew >/dev/null 2>&1; then
                    brew install eza
                    log_success "eza installed successfully"
                else
                    log_error "Homebrew not found. Please install Homebrew first."
                    return 1
                fi
                ;;

            Linux)
                case "$distro" in
                    arch)
                        log_info "Installing eza via pacman/yay on Arch Linux..."
                        if command -v yay >/dev/null 2>&1; then
                            yay -S --noconfirm eza
                        else
                            sudo pacman -S --noconfirm eza
                        fi
                        log_success "eza installed successfully"
                        ;;

                    debian|ubuntu)
                        log_info "Installing eza on Debian/Ubuntu..."

                        # Check Ubuntu version for official package support
                        if command -v lsb_release >/dev/null 2>&1; then
                            local ubuntu_version
                            ubuntu_version=$(lsb_release -rs 2>/dev/null | cut -d. -f1)

                            # Ubuntu 24.04+ has eza in official repos
                            if [[ "$ubuntu_version" -ge 24 ]] 2>/dev/null; then
                                log_info "Installing from official repository (Ubuntu 24.04+)..."
                                sudo apt update
                                sudo apt install -y eza
                                log_success "eza installed successfully"
                                return 0
                            fi
                        fi

                        # Fallback: Install from GitHub releases
                        log_info "Installing from GitHub releases..."
                        local arch="$(uname -m)"
                        local eza_arch

                        case "$arch" in
                            x86_64)
                                eza_arch="x86_64"
                                ;;
                            aarch64|arm64)
                                eza_arch="aarch64"
                                ;;
                            *)
                                log_error "Unsupported architecture: $arch"
                                return 1
                                ;;
                        esac

                        # Create temporary directory
                        local temp_dir
                        temp_dir=$(mktemp -d)

                        # Download latest release
                        log_info "Downloading eza for $eza_arch..."
                        local download_url="https://github.com/eza-community/eza/releases/latest/download/eza_${eza_arch}-unknown-linux-gnu.tar.gz"

                        if curl -L "$download_url" -o "$temp_dir/eza.tar.gz"; then
                            # Extract and install
                            tar xzf "$temp_dir/eza.tar.gz" -C "$temp_dir"

                            # Install to user bin directory
                            mkdir -p "$HOME/.local/bin"
                            mv "$temp_dir/eza" "$HOME/.local/bin/"
                            chmod +x "$HOME/.local/bin/eza"

                            # Add to PATH for current session
                            export PATH="$HOME/.local/bin:$PATH"

                            log_success "eza installed successfully to ~/.local/bin/eza"
                        else
                            log_error "Failed to download eza"
                            rm -rf "$temp_dir"
                            return 1
                        fi

                        # Cleanup
                        rm -rf "$temp_dir"
                        ;;

                    *)
                        log_warning "Unsupported distribution: $distro"
                        log_info "Attempting to install via cargo..."

                        if command -v cargo >/dev/null 2>&1; then
                            cargo install eza
                            log_success "eza installed via cargo"
                        else
                            log_error "cargo not found. Please install Rust toolchain or install eza manually."
                            return 1
                        fi
                        ;;
                esac
                ;;

            *)
                log_error "Unsupported OS: $os_name"
                return 1
                ;;
        esac

        # Verify installation
        if command -v eza >/dev/null 2>&1; then
            log_info "eza version: $(eza --version | head -1)"
        else
            log_error "eza installation verification failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install eza for $os_name ($distro)"
    fi
}

# Main installation function
main() {
    log_info "eza (Modern ls Replacement) Setup"
    log_info "================================="

    # Parse command line options
    parse_install_options "$@"

    # Get target eza version
    local eza_version="${EZA_VERSION:-0.10.0}"

    # Check if eza installation should be skipped
    if should_skip_installation_advanced "eza" "eza" "$eza_version" "--version"; then
        log_info "eza is already installed"
        check_eza_version_requirements
        return 0
    fi

    # Install eza
    install_eza "$@"

    log_success "eza setup completed!"
    log_info ""
    log_info "Available eza commands:"
    log_info "  eza                  # List files (basic)"
    log_info "  eza -l               # Long format"
    log_info "  eza -la              # Long format with hidden files"
    log_info "  eza -lh              # Long format with human-readable sizes"
    log_info "  eza --tree           # Tree view"
    log_info "  eza --git            # Show git status"
    log_info "  eza --icons          # Show file icons (requires Nerd Font)"
    log_info ""
    log_info "Aliases (defined in .config/zsh/zshrc/alias.zsh):"
    log_info "  ls, la, ll, etc.     # Use 'eza' instead of traditional 'ls'"
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current status:"
        log_info "  eza version: $(eza --version 2>/dev/null | head -1 || echo 'not available')"
        log_info "  Install location: $(which eza 2>/dev/null || echo 'not in PATH')"
    fi
    log_info ""
    log_info "Documentation: https://eza.rocks/"
}

# Run main function
main "$@"
