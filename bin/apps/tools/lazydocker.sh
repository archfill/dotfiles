#!/usr/bin/env bash

# lazydocker (Docker management TUI) installation script
# This script installs lazydocker across different platforms

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting lazydocker (Docker management TUI) setup..."

# Check lazydocker installation
check_lazydocker_environment() {
    log_info "Checking lazydocker environment..."

    if ! is_command_available "lazydocker" "--version"; then
        log_info "lazydocker not available"
        return 1
    fi

    log_success "lazydocker environment checks passed"
    return 0
}

# Check lazydocker version requirements
check_lazydocker_version_requirements() {
    local required_version="${LAZYDOCKER_VERSION:-0.20.0}"

    log_info "Checking lazydocker version requirements (>= $required_version)..."

    if ! command -v lazydocker >/dev/null 2>&1; then
        log_info "lazydocker command not available"
        return 1
    fi

    # lazydocker version output format: "Version: 0.23.3"
    local current_version
    current_version=$(lazydocker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine lazydocker version"
        return 1
    fi

    compare_versions "$current_version" "$required_version"
    local result=$?

    case $result in
        0|2)  # current >= required
            log_success "lazydocker version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "lazydocker version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for lazydocker"
            return 1
            ;;
    esac
}

# Install lazydocker
install_lazydocker() {
    log_info "Installing lazydocker..."

    # Parse command line options
    parse_install_options "$@"

    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install lazydocker"
        return 0
    fi

    local distro="$(get_os_distribution)"
    local os_name="$(uname -s)"

    if [[ "$DRY_RUN" != "true" ]]; then
        case "$os_name" in
            Darwin)
                log_info "Installing lazydocker via Homebrew on macOS..."
                if command -v brew >/dev/null 2>&1; then
                    brew install lazydocker
                    log_success "lazydocker installed successfully"
                else
                    log_error "Homebrew not found. Please install Homebrew first."
                    return 1
                fi
                ;;

            Linux)
                case "$distro" in
                    arch)
                        log_info "Installing lazydocker via pacman/yay on Arch Linux..."
                        if command -v yay >/dev/null 2>&1; then
                            yay -S --noconfirm lazydocker
                        else
                            sudo pacman -S --noconfirm lazydocker
                        fi
                        log_success "lazydocker installed successfully"
                        ;;

                    debian|ubuntu)
                        log_info "Installing lazydocker on Debian/Ubuntu..."
                        log_info "Using official installation script..."

                        # Download and execute official install script
                        # This script installs to ~/.local/bin by default
                        if curl -sSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash; then
                            log_success "lazydocker installed successfully to ~/.local/bin/lazydocker"

                            # Add to PATH for current session
                            export PATH="$HOME/.local/bin:$PATH"
                        else
                            log_error "Failed to install lazydocker via official script"
                            return 1
                        fi
                        ;;

                    *)
                        log_warning "Unsupported distribution: $distro"
                        log_info "Attempting to install via official script..."

                        if curl -sSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash; then
                            log_success "lazydocker installed successfully"
                            export PATH="$HOME/.local/bin:$PATH"
                        else
                            log_error "Installation failed. Please install manually from: https://github.com/jesseduffield/lazydocker"
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
        if command -v lazydocker >/dev/null 2>&1; then
            log_info "lazydocker version: $(lazydocker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
        else
            log_error "lazydocker installation verification failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install lazydocker for $os_name ($distro)"
    fi
}

# Main installation function
main() {
    log_info "lazydocker (Docker Management TUI) Setup"
    log_info "========================================="

    # Parse command line options
    parse_install_options "$@"

    # Get target lazydocker version
    local lazydocker_version="${LAZYDOCKER_VERSION:-0.20.0}"

    # Check if lazydocker installation should be skipped
    if should_skip_installation_advanced "lazydocker" "lazydocker" "$lazydocker_version" "--version"; then
        log_info "lazydocker is already installed"
        check_lazydocker_version_requirements
        return 0
    fi

    # Install lazydocker
    install_lazydocker "$@"

    log_success "lazydocker setup completed!"
    log_info ""
    log_info "Usage: lazydocker"
    log_info ""
    log_info "Key features:"
    log_info "  • Interactive Docker management TUI"
    log_info "  • View logs, stats, and manage containers/images"
    log_info "  • Easy navigation with keyboard shortcuts"
    log_info "  • Support for docker-compose"
    log_info ""
    log_info "Keyboard shortcuts:"
    log_info "  x     - Open menu for container/image actions"
    log_info "  e     - View logs"
    log_info "  m     - View stats"
    log_info "  d     - Delete container/image"
    log_info "  [/]   - Previous/Next panel"
    log_info "  ?     - Show help"
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current status:"
        log_info "  lazydocker version: $(lazydocker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo 'not available')"
        log_info "  Install location: $(which lazydocker 2>/dev/null || echo 'not in PATH')"
    fi
    log_info ""
    log_info "Documentation: https://github.com/jesseduffield/lazydocker"
}

# Run main function
main "$@"
