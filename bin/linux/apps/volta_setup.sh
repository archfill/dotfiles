#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/../../lib/common.sh"

setup_error_handling

log_info "Setting up Volta for Linux environment..."

# Check if Volta is already installed
if command -v volta >/dev/null 2>&1; then
    log_info "Volta is already installed"
    volta --version
else
    log_info "Installing Volta..."
    
    # Install Volta via official installer
    if ! curl -fsSL https://get.volta.sh | bash; then
        log_error "Failed to install Volta"
        exit 1
    fi
    
    log_success "Volta installation completed"
fi

# Add Volta to PATH for current session
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Install Node.js LTS and npm if Volta is available
if command -v volta >/dev/null 2>&1; then
    log_info "Installing Node.js LTS and npm..."
    volta install node@lts
    volta install npm@latest
    
    log_success "Node.js toolchain setup completed"
    log_info "Installed versions:"
    volta list
    
    log_info "Volta setup completed successfully!"
    log_info "Usage examples:"
    log_info "  volta pin node@18    # Pin Node.js 18 for this project"
    log_info "  volta pin npm@9      # Pin npm 9 for this project"
    log_info "  volta install yarn   # Install Yarn globally"
else
    log_error "Volta installation verification failed"
    exit 1
fi