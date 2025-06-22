#!/usr/bin/env bash
# Starship (cross-shell prompt) installer

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_DIR/bin/lib/common.sh"

# Setup standardized error handling
setup_error_handling

log_info "Installing Starship cross-shell prompt..."

# Check if starship is already installed
if command -v starship &> /dev/null; then
    log_success "Starship is already installed: $(starship --version)"
    exit 0
fi

# Install starship to ~/.local/bin
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
    log_info "Created ~/.local/bin directory"
fi

# Download and install starship
log_info "Downloading Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin --yes

if [ $? -eq 0 ]; then
    log_success "Starship installed successfully"
    log_info "Note: Starship configuration will be managed via symlinks (run bin/link.sh)"
    log_success "Starship setup completed"
else
    log_error "Failed to install Starship"
    exit 1
fi