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
    local ghq_version
    local arch
    local os
    local download_url
    local install_dir="$HOME/.local/bin"
    
    # Get latest version from GitHub API
    log_info "Fetching latest ghq version from GitHub..."
    ghq_version=$(curl -s --connect-timeout 10 "https://api.github.com/repos/x-motemen/ghq/releases/latest" 2>/dev/null | \
        grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 2>/dev/null)
    
    if [[ -z "$ghq_version" ]]; then
        # Fallback to known version
        ghq_version="v1.6.2"
        log_info "API fetch failed, using fallback version: $ghq_version"
    else
        log_info "Latest ghq version: $ghq_version"
    fi
    
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
    
    # Download and extract
    local temp_file
    temp_file=$(mktemp)
    
    if curl -fsSL "$download_url" -o "$temp_file"; then
        # Verify the downloaded file
        if file "$temp_file" | grep -q "gzip compressed"; then
            # Extract ghq binary
            if tar -xzf "$temp_file" -C "$install_dir" --strip-components=1 --wildcards "*/ghq" 2>/dev/null; then
                chmod +x "$install_dir/ghq"
                log_success "ghq binary installed to $install_dir/ghq"
            else
                # Try alternative extraction method
                local temp_dir
                temp_dir=$(mktemp -d)
                tar -xzf "$temp_file" -C "$temp_dir"
                
                # Find ghq binary
                local ghq_binary
                ghq_binary=$(find "$temp_dir" -name "ghq" -type f | head -1)
                
                if [[ -n "$ghq_binary" ]]; then
                    cp "$ghq_binary" "$install_dir/ghq"
                    chmod +x "$install_dir/ghq"
                    log_success "ghq binary installed to $install_dir/ghq"
                else
                    log_error "ghq binary not found in archive"
                    rm -rf "$temp_dir"
                    exit 1
                fi
                
                rm -rf "$temp_dir"
            fi
        else
            log_error "Downloaded file is not a valid gzip archive"
            head -n 5 "$temp_file"
            exit 1
        fi
    else
        log_error "Failed to download ghq from: $download_url"
        exit 1
    fi
    
    rm -f "$temp_file"
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