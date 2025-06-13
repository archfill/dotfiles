#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/../lib/common.sh"

setup_error_handling

log_info "Installing ghq (Git repository management tool)..."

# Function to install ghq on different platforms
install_ghq() {
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        "Darwin")
            if command -v brew >/dev/null 2>&1; then
                log_info "Installing ghq via Homebrew..."
                brew install ghq
            else
                log_error "Homebrew not found on macOS"
                exit 1
            fi
            ;;
        "Linux"|"Linux_WSL")
            if command -v go >/dev/null 2>&1; then
                log_info "Installing ghq via go install..."
                go install github.com/x-motemen/ghq@latest
            else
                log_info "Go not found, installing ghq binary..."
                install_ghq_binary_linux
            fi
            ;;
        "Termux")
            log_info "Installing ghq via pkg (Termux)..."
            pkg install ghq
            ;;
        "Cygwin")
            log_info "Installing ghq binary for Cygwin..."
            install_ghq_binary_linux
            ;;
        *)
            log_warning "Unsupported platform: $platform"
            log_info "Attempting to install ghq binary..."
            install_ghq_binary_linux
            ;;
    esac
}

# Function to install ghq binary on Linux-like systems
install_ghq_binary_linux() {
    local ghq_version="v1.4.2"  # Latest stable version
    local arch
    local os
    local download_url
    local install_dir="$HOME/.local/bin"
    
    # Detect architecture
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        i386|i686) arch="386" ;;
        armv7l) arch="arm" ;;
        aarch64|arm64) arch="arm64" ;;
        *) 
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    
    # Detect OS
    case "$(uname -s)" in
        Linux*) os="linux" ;;
        Darwin*) os="darwin" ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *)
            log_error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
    
    download_url="https://github.com/x-motemen/ghq/releases/download/${ghq_version}/ghq_${os}_${arch}.tar.gz"
    
    log_info "Downloading ghq from: $download_url"
    
    # Create install directory
    mkdir -p "$install_dir"
    
    # Download and install
    if curl -fsSL "$download_url" | tar -xz -C "$install_dir" --strip-components=1 ghq_${os}_${arch}/ghq; then
        chmod +x "$install_dir/ghq"
        log_success "ghq binary installed to $install_dir/ghq"
    else
        log_error "Failed to download and install ghq binary"
        exit 1
    fi
}

# Function to setup ghq configuration
setup_ghq_config() {
    local ghq_root="$HOME/git"
    
    log_info "Setting up ghq configuration..."
    
    # Create ghq root directory
    mkdir -p "$ghq_root"
    
    # Set git config for ghq
    log_info "Setting ghq.root to $ghq_root"
    git config --global ghq.root "$ghq_root"
    
    # Verify configuration
    local configured_root
    configured_root=$(git config --global ghq.root)
    if [[ "$configured_root" == "$ghq_root" ]]; then
        log_success "ghq.root configured successfully: $configured_root"
    else
        log_error "Failed to configure ghq.root"
        exit 1
    fi
}

# Function to verify ghq installation
verify_ghq_installation() {
    log_info "Verifying ghq installation..."
    
    if command -v ghq >/dev/null 2>&1; then
        local version
        version=$(ghq --version)
        log_success "ghq installed successfully: $version"
        
        # Show current configuration
        log_info "Current ghq configuration:"
        echo "  ghq.root: $(git config --global ghq.root)"
        
        # Show usage examples
        log_info "Usage examples:"
        echo "  ghq get github.com/user/repo    # Clone repository"
        echo "  ghq list                         # List repositories"
        echo "  ghq root                         # Show root directory"
        echo "  g                                # Interactive project selection (zsh function)"
        
        return 0
    else
        log_error "ghq verification failed - command not found"
        return 1
    fi
}

# Main execution
main() {
    # Check if ghq is already installed
    if command -v ghq >/dev/null 2>&1; then
        log_success "ghq is already installed: $(ghq --version)"
        setup_ghq_config
        verify_ghq_installation
        return 0
    fi
    
    # Install ghq
    install_ghq
    
    # Setup configuration
    setup_ghq_config
    
    # Verify installation
    verify_ghq_installation
    
    log_success "ghq setup completed successfully"
}

# Run main function
main "$@"