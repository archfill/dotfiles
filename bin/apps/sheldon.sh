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
    log_success "Sheldon setup completed"
else
    log_error "Failed to install Sheldon"
    exit 1
fi