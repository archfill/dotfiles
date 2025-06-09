#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/../lib/common.sh"

setup_error_handling

log_info "Installing Volta (JavaScript toolchain manager)..."

# Install Volta
if ! curl -fsSL https://get.volta.sh | bash; then
    log_error "Failed to install Volta"
    exit 1
fi

# Add Volta to PATH for current session
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Install latest Node.js LTS and npm
log_info "Installing Node.js LTS and npm..."
if command -v volta >/dev/null 2>&1; then
    volta install node@lts
    volta install npm@latest
    
    log_success "Volta setup completed successfully"
    log_info "Installed versions:"
    volta list
    log_info "Usage: volta pin node@18 (to pin project Node.js version)"
else
    log_error "Volta installation failed - command not found"
    exit 1
fi
