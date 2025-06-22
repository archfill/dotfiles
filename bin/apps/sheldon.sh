#!/usr/bin/env bash
# Sheldon (zsh plugin manager) installer

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_DIR/bin/lib/common.sh"

# Setup standardized error handling
setup_error_handling

log_info "Installing Sheldon zsh plugin manager..."

# Check if sheldon is already installed
if command -v sheldon &> /dev/null; then
    log_success "Sheldon is already installed: $(sheldon --version)"
    exit 0
fi

# Install sheldon to ~/.local/bin
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
    log_info "Created ~/.local/bin directory"
fi

# Download and install sheldon
log_info "Downloading Sheldon..."
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

if [ $? -eq 0 ]; then
    log_success "Sheldon installed successfully"
    log_info "Note: Sheldon configuration will be managed via symlinks (run bin/link.sh)"
    
    # Install additional modern CLI tools
    log_info "Installing additional modern CLI tools..."
    
    # Install zoxide (smart cd command)
    if ! command -v zoxide &> /dev/null; then
        log_info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        if [ $? -eq 0 ]; then
            log_success "zoxide installed successfully"
        else
            log_error "Failed to install zoxide"
        fi
    else
        log_success "zoxide is already installed"
    fi
    
    # Install eza (modern ls replacement)
    if ! command -v eza &> /dev/null; then
        log_info "Installing eza..."
        if command -v cargo &> /dev/null; then
            cargo install eza
            if [ $? -eq 0 ]; then
                log_success "eza installed successfully"
            else
                log_error "Failed to install eza via cargo"
            fi
        else
            log_warning "Cargo not found, skipping eza installation"
        fi
    else
        log_success "eza is already installed"
    fi
    
    # Install bat (modern cat replacement)
    if ! command -v bat &> /dev/null; then
        log_info "Installing bat..."
        if command -v cargo &> /dev/null; then
            cargo install bat
            if [ $? -eq 0 ]; then
                log_success "bat installed successfully"
            else
                log_error "Failed to install bat via cargo"
            fi
        else
            log_warning "Cargo not found, skipping bat installation"
        fi
    else
        log_success "bat is already installed"
    fi
    
    log_success "Sheldon setup completed"
else
    log_error "Failed to install Sheldon"
    exit 1
fi