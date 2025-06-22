#!/usr/bin/env bash

# Rust toolchain installation script using rustup
# This script installs rustup and Rust stable toolchain

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Rust toolchain setup via rustup..."

# Install rustup
install_rustup() {
  log_info "Installing rustup..."
  
  # Check if rustup is already installed
  if command -v rustup >/dev/null 2>&1; then
    log_success "rustup is already installed: $(rustup --version)"
    return 0
  fi
  
  # Set environment variables for non-interactive installation
  export RUSTUP_INIT_SKIP_PATH_CHECK=yes
  
  # Download and install rustup
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
  
  # Source Rust environment
  source "$HOME/.cargo/env"
  
  if command -v rustup >/dev/null 2>&1; then
    log_success "rustup installed successfully"
  else
    log_error "rustup installation failed"
    exit 1
  fi
}

# Install and setup Rust stable toolchain
setup_rust_toolchain() {
  log_info "Setting up Rust stable toolchain..."
  
  # Ensure rustup is available
  if ! command -v rustup >/dev/null 2>&1; then
    if [[ -f "$HOME/.cargo/env" ]]; then
      source "$HOME/.cargo/env"
    else
      log_error "rustup not found"
      exit 1
    fi
  fi
  
  # Update rustup
  log_info "Updating rustup..."
  rustup self update
  
  # Install stable toolchain (if not already default)
  log_info "Installing Rust stable toolchain..."
  rustup toolchain install stable
  
  # Set stable as default
  rustup default stable
  
  # Update stable toolchain
  log_info "Updating Rust stable toolchain..."
  rustup update stable
  
  # Verify installation
  verify_rust_installation
}

# Install essential Rust components
install_rust_components() {
  log_info "Installing essential Rust components..."
  
  # Ensure rustup is available
  if ! command -v rustup >/dev/null 2>&1; then
    source "$HOME/.cargo/env"
  fi
  
  # Install clippy (linter)
  log_info "Installing clippy..."
  rustup component add clippy
  
  # Install rustfmt (formatter)
  log_info "Installing rustfmt..."
  rustup component add rustfmt
  
  # Install rust-analyzer (LSP server) via rustup if available
  log_info "Installing rust-analyzer..."
  if rustup component list | grep -q "rust-analyzer"; then
    rustup component add rust-analyzer
  else
    log_info "rust-analyzer not available via rustup, will be installed via Mason"
  fi
  
  # Install rust-src for better IDE support
  log_info "Installing rust-src..."
  rustup component add rust-src
  
  log_success "Essential Rust components installed"
}

# Install useful Rust tools
install_rust_tools() {
  log_info "Installing useful Rust tools..."
  
  # Ensure cargo is available
  if ! command -v cargo >/dev/null 2>&1; then
    source "$HOME/.cargo/env"
  fi
  
  # List of useful Rust tools
  local tools=(
    "cargo-edit"        # cargo add, cargo rm commands
    "cargo-watch"       # cargo watch for auto-recompilation
    "cargo-outdated"    # Check for outdated dependencies
    "cargo-audit"       # Security audit for dependencies
  )
  
  for tool in "${tools[@]}"; do
    if ! cargo install --list | grep -q "^$tool"; then
      log_info "Installing $tool..."
      cargo install "$tool" || log_warning "Failed to install $tool"
    else
      log_info "$tool is already installed"
    fi
  done
  
  log_success "Rust tools installation completed"
}

# Verify Rust installation
verify_rust_installation() {
  log_info "Verifying Rust installation..."
  
  # Source Rust environment if needed
  if ! command -v rustc >/dev/null 2>&1; then
    if [[ -f "$HOME/.cargo/env" ]]; then
      source "$HOME/.cargo/env"
    fi
  fi
  
  if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
    log_success "Rust installed successfully!"
    log_info "Rust version: $(rustc --version)"
    log_info "Cargo version: $(cargo --version)"
    
    # Show toolchain info
    log_info "Active toolchain: $(rustup show active-toolchain)"
    
    # Show installed components
    log_info "Installed components:"
    rustup component list --installed
    
    # Show environment info
    if [[ -n "${CARGO_HOME:-}" ]]; then
      log_info "CARGO_HOME: $CARGO_HOME"
    fi
    if [[ -n "${RUSTUP_HOME:-}" ]]; then
      log_info "RUSTUP_HOME: $RUSTUP_HOME"
    fi
  else
    log_error "Rust installation verification failed"
    log_info "Please restart your shell and try again"
    exit 1
  fi
}

# Setup Rust environment for current shell
setup_rust_environment() {
  log_info "Setting up Rust environment..."
  
  # Source Rust environment
  if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
    log_success "Rust environment loaded for current shell"
  fi
  
  # Set environment variables if not already set
  export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
  export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
  
  log_info "CARGO_HOME: $CARGO_HOME"
  log_info "RUSTUP_HOME: $RUSTUP_HOME"
}

# Install additional targets (optional)
install_additional_targets() {
  log_info "Installing additional compilation targets..."
  
  # Ensure rustup is available
  if ! command -v rustup >/dev/null 2>&1; then
    source "$HOME/.cargo/env"
  fi
  
  # List of useful targets
  local targets=(
    "wasm32-unknown-unknown"  # WebAssembly
    "x86_64-unknown-linux-musl"  # Static linking on Linux
  )
  
  for target in "${targets[@]}"; do
    log_info "Installing target: $target"
    rustup target add "$target" || log_warning "Failed to install target: $target"
  done
  
  log_success "Additional targets installation completed"
}

# Main installation function
main() {
  log_info "Rust Toolchain Setup via rustup"
  log_info "==============================="
  
  # Install rustup
  install_rustup
  
  # Setup Rust toolchain
  setup_rust_toolchain
  
  # Install essential components
  install_rust_components
  
  # Setup environment
  setup_rust_environment
  
  # Install useful tools
  install_rust_tools
  
  # Install additional targets
  install_additional_targets
  
  log_success "Rust toolchain setup completed!"
  log_info ""
  log_info "Available rustup commands:"
  log_info "  rustup show             # Show active toolchain and targets"
  log_info "  rustup update           # Update all toolchains"
  log_info "  rustup toolchain list   # List installed toolchains"
  log_info "  rustup target list      # List available targets"
  log_info "  cargo --version         # Show Cargo version"
  log_info "  cargo new <project>     # Create new Rust project"
  log_info ""
  log_info "Available cargo tools:"
  log_info "  cargo watch            # Auto-recompile on file changes"
  log_info "  cargo add <crate>       # Add dependency to Cargo.toml"
  log_info "  cargo outdated          # Check for outdated dependencies"
  log_info "  cargo audit             # Security audit"
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"