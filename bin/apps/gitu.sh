#!/usr/bin/env bash

# gitu installation script
# A TUI Git client inspired by Magit

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

setup_error_handling

# Load configuration
load_config

log_info "Installing gitu - TUI Git client inspired by Magit"

# Function to install gitu via cargo
install_gitu_cargo() {
    log_info "Installing gitu via cargo..."
    
    # Check if cargo is available
    if ! command -v cargo >/dev/null 2>&1; then
        log_error "cargo not found. Please install Rust and Cargo first."
        log_info "Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        return 1
    fi
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install gitu via cargo"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Install gitu via cargo
        log_info "Installing gitu version ${GITU_VERSION:-latest}..."
        if cargo install gitu; then
            log_success "gitu installed successfully via cargo"
            
            # Add to PATH info
            if [[ -d "$HOME/.cargo/bin" ]]; then
                log_info "gitu binary location: $HOME/.cargo/bin/gitu"
                log_info "Make sure $HOME/.cargo/bin is in your PATH"
            fi
            
            # Show version
            if command -v gitu >/dev/null 2>&1; then
                local version=$(gitu --version 2>/dev/null || echo "unknown")
                log_success "Installed gitu version: $version"
            fi
            
            return 0
        else
            log_error "Failed to install gitu via cargo"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install gitu via cargo"
    fi
}

# Function to install gitu on Arch Linux
install_gitu_arch() {
    log_info "Installing gitu on Arch Linux..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install gitu via pacman/yay"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Try pacman first (official repo)
        if sudo pacman -S --noconfirm gitu 2>/dev/null; then
            log_success "gitu installed successfully via pacman"
            return 0
        # Fallback to yay if available
        elif command -v yay >/dev/null 2>&1; then
            log_info "Trying installation via yay..."
            if yay -S --noconfirm gitu; then
                log_success "gitu installed successfully via yay"
                return 0
            fi
        fi
        
        log_warning "Package manager installation failed, falling back to cargo"
        install_gitu_cargo "$@"
    else
        log_info "[DRY RUN] Would install gitu via pacman/yay"
    fi
}

# Function to install gitu on macOS
install_gitu_macos() {
    log_info "Installing gitu on macOS..."
    
    # Parse command line options  
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install gitu via Homebrew"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Try Homebrew
        if command -v brew >/dev/null 2>&1; then
            if brew install gitu; then
                log_success "gitu installed successfully via Homebrew"
                return 0
            fi
        fi
        
        log_warning "Homebrew installation failed, falling back to cargo"
        install_gitu_cargo "$@"
    else
        log_info "[DRY RUN] Would install gitu via Homebrew"
    fi
}

# Main installation function
main() {
    log_info "gitu Installation"
    log_info "=================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if gitu should be skipped
    if should_skip_installation_simple "gitu" "gitu"; then
        return 0
    fi
    
    # Check if already installed
    if command -v gitu >/dev/null 2>&1 && [[ "$FORCE_INSTALL" != "true" ]]; then
        local current_version=$(gitu --version 2>/dev/null || echo "unknown")
        log_skip_reason "gitu" "Already installed: $current_version"
        return 0
    fi
    
    # Detect OS and install accordingly
    local os_name=$(uname -s)
    case "$os_name" in
        "Darwin")
            install_gitu_macos "$@"
            ;;
        "Linux")
            # Detect distribution
            local distro=$(get_os_distribution)
            case "$distro" in
                "arch")
                    install_gitu_arch "$@"
                    ;;
                "debian"|"ubuntu")
                    log_info "gitu is not available in Debian/Ubuntu repositories"
                    install_gitu_cargo "$@"
                    ;;
                *)
                    log_warning "Unsupported Linux distribution: $distro"
                    install_gitu_cargo "$@"
                    ;;
            esac
            ;;
        *)
            log_warning "Unsupported OS: $os_name"
            install_gitu_cargo "$@"
            ;;
    esac
    
    # Post-installation setup
    if command -v gitu >/dev/null 2>&1; then
        log_success "gitu installation completed!"
        
        # Show basic usage
        log_info ""
        log_info "Usage:"
        log_info "  gitu                # Start gitu in current git repository"
        log_info "  gitu -h             # Show help"
        log_info ""
        log_info "Key bindings (press 'h' in gitu for help):"
        log_info "  ?/h       - Show help"
        log_info "  q         - Quit"
        log_info "  g/r       - Refresh"
        log_info "  Tab       - Navigate sections"
        log_info "  s         - Stage/unstage files"
        log_info "  c         - Commit"
        log_info ""
        log_info "Note: gitu is inspired by Magit and provides a terminal UI for Git"
    else
        log_error "gitu installation verification failed"
        return 1
    fi
}

# Run main function
main "$@"