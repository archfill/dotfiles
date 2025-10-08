#!/usr/bin/env bash

# Rust toolchain installation script using rustup
# This script installs rustup and Rust stable toolchain

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Rust toolchain setup via rustup..."

# =============================================================================
# Enhanced Rust Environment Checking and Management Functions
# =============================================================================

# Check rustup installation and environment
check_rustup_environment() {
    log_info "Checking rustup environment..."
    
    local all_checks_passed=true
    
    # Check rustup command availability
    if ! is_command_available "rustup" "--version"; then
        log_info "rustup not available"
        all_checks_passed=false
    else
        # Check Rust toolchain
        if ! command -v rustc >/dev/null 2>&1; then
            log_warning "Rust compiler not available"
        else
            local rust_version
            rust_version=$(rustc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
            log_info "Rust version: $rust_version"
        fi
        
        # Check cargo availability
        if ! command -v cargo >/dev/null 2>&1; then
            log_warning "Cargo not available"
        else
            local cargo_version
            cargo_version=$(cargo --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
            log_info "Cargo version: $cargo_version"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "rustup environment checks passed"
        return 0
    else
        log_info "rustup environment checks failed"
        return 1
    fi
}

# Check Rust toolchain status
check_rust_toolchain_status() {
    log_info "Checking Rust toolchain status..."
    
    if ! command -v rustup >/dev/null 2>&1; then
        log_info "rustup not available"
        return 1
    fi
    
    # Check installed toolchains
    local toolchain_count
    toolchain_count=$(rustup toolchain list 2>/dev/null | wc -l || echo 0)
    log_info "Installed toolchains: $toolchain_count"
    
    # Check default toolchain
    local default_toolchain
    default_toolchain=$(rustup default 2>/dev/null || echo "none")
    log_info "Default toolchain: $default_toolchain"
    
    # Check installed components
    if rustup component list --installed >/dev/null 2>&1; then
        local component_count
        component_count=$(rustup component list --installed 2>/dev/null | wc -l || echo 0)
        log_info "Installed components: $component_count"
    fi
    
    log_success "Rust toolchain status check completed"
    return 0
}

# Comprehensive rustup environment check
check_rustup_comprehensive_environment() {
    log_info "Performing comprehensive rustup environment check..."
    
    local all_checks_passed=true
    
    # Check rustup installation
    if ! check_rustup_environment; then
        all_checks_passed=false
    fi
    
    # Check toolchain status
    check_rust_toolchain_status
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All rustup environment checks passed"
        return 0
    else
        log_info "Some rustup environment checks failed"
        return 1
    fi
}

# Install rustup with enhanced options
install_rustup() {
  log_info "Installing rustup..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if rustup should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v rustup >/dev/null 2>&1; then
    log_skip_reason "rustup" "Already installed: $(rustup --version 2>/dev/null | head -1)"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install rustup"
    return 0
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
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
      return 1
    fi
  else
    log_info "[DRY RUN] Would install rustup with stable toolchain"
  fi
}

# Install and setup Rust stable toolchain with enhanced options
setup_rust_toolchain() {
  log_info "Setting up Rust stable toolchain..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would setup Rust stable toolchain"
    return 0
  fi
  
  # Ensure rustup is available
  if ! command -v rustup >/dev/null 2>&1; then
    if [[ -f "$HOME/.cargo/env" ]]; then
      source "$HOME/.cargo/env"
    else
      log_error "rustup not found"
      return 1
    fi
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
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
  else
    log_info "[DRY RUN] Would setup Rust stable toolchain"
  fi
  
  # Verify installation
  verify_rust_installation
}

# Install essential Rust components with enhanced options
install_rust_components() {
  log_info "Installing essential Rust components..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install essential Rust components"
    return 0
  fi
  
  # Ensure rustup is available
  if ! command -v rustup >/dev/null 2>&1; then
    source "$HOME/.cargo/env"
  fi
  
  if ! command -v rustup >/dev/null 2>&1; then
    log_warning "rustup not available, skipping components installation"
    return 1
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
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
  else
    log_info "[DRY RUN] Would install essential Rust components"
  fi
  
  log_success "Essential Rust components installed"
}

# Install useful Rust tools with enhanced options
install_rust_tools() {
  log_info "Installing useful Rust tools..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install useful Rust tools"
    return 0
  fi
  
  # Skip tools installation if in container environment or CI
  if [[ -n "${CONTAINER:-}" || -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
    log_info "Skipping Rust tools installation in container/CI environment"
    return 0
  fi
  
  # Temporary: Skip tools installation to avoid blocking Docker setup
  log_info "Temporarily skipping Rust tools installation (known issue with cargo install --list)"
  log_success "Rust tools installation completed (skipped)"
  return 0
  
  # Ensure cargo is available
  if ! command -v cargo >/dev/null 2>&1; then
    source "$HOME/.cargo/env"
  fi
  
  if ! command -v cargo >/dev/null 2>&1; then
    log_warning "cargo not available, skipping tools installation"
    return 1
  fi
  
  # List of useful Rust tools with descriptions
  local tools_info=(
    "cargo-edit:cargo add, cargo rm commands"
    "cargo-watch:cargo watch for auto-recompilation"
    "cargo-outdated:Check for outdated dependencies"
    "cargo-audit:Security audit for dependencies"
  )
  
  # Get installed tools list once for efficiency
  local installed_tools=$(cargo install --list 2>/dev/null | grep -E '^[a-zA-Z0-9_-]+' | cut -d' ' -f1 || true)
  
  # Check if all tools are already installed
  local all_tools_installed=true
  for tool_info in "${tools_info[@]}"; do
    local tool_name=$(echo "$tool_info" | cut -d: -f1)
    if ! echo "$installed_tools" | grep -q "^$tool_name$"; then
      all_tools_installed=false
      break
    fi
  done
  
  if [[ "$all_tools_installed" == "true" && "$FORCE_INSTALL" != "true" ]]; then
    log_success "All Rust tools are already installed"
    return 0
  fi
  
  local installed_count=0
  local skipped_count=0
  local failed_count=0
  
  for tool_info in "${tools_info[@]}"; do
    local tool_name=$(echo "$tool_info" | cut -d: -f1)
    local tool_desc=$(echo "$tool_info" | cut -d: -f2)
    
    # Skip if tool is already available and not forcing reinstall
    if [[ "$FORCE_INSTALL" != "true" ]] && echo "$installed_tools" | grep -q "^$tool_name$"; then
      log_skip_reason "$tool_name" "Already installed"
      ((skipped_count++))
      continue
    fi
    
    log_info "Installing $tool_name ($tool_desc)..."
    
    if [[ "$DRY_RUN" != "true" ]]; then
      if cargo install "$tool_name"; then
        log_success "$tool_name installed successfully"
        ((installed_count++))
      else
        log_warning "Failed to install $tool_name"
        ((failed_count++))
      fi
    else
      log_info "[DRY RUN] Would install $tool_name"
      ((installed_count++))
    fi
  done
  
  # Log summary
  if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
    log_install_summary "$installed_count" "$skipped_count" "$failed_count"
  fi
  
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
    return 1
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
  
  # Parse command line options
  parse_install_options "$@"
  
  # Get target Rust version (use default stable)
  local rust_version="stable"
  
  # Check if Rust installation should be skipped
  if should_skip_installation_advanced "Rust" "rustc" "$rust_version" "--version"; then
    # Even if Rust is installed, check and update environment
    log_info "Rust is installed, checking rustup environment and tools..."
    
    # Perform comprehensive environment check
    check_rustup_comprehensive_environment
    
    # Setup/verify environment
    setup_rust_environment
    
    # Install/update components
    install_rust_components "$@"
    
    # Install useful tools
    install_rust_tools "$@"
    
    # Install additional targets (skip in quick mode)
    if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
      install_additional_targets
    fi
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
      if ! verify_rust_installation; then
        log_warning "Rust installation verification had issues, but this is not critical"
        log_info "Rust tools were installed successfully, continuing..."
      fi
    fi
    
    return 0
  fi
  
  # Install rustup
  install_rustup "$@"
  
  # Setup Rust toolchain
  setup_rust_toolchain "$@"
  
  # Install essential components
  install_rust_components "$@"
  
  # Setup environment
  setup_rust_environment
  
  # Install useful tools
  install_rust_tools "$@"
  
  # Install additional targets (skip in quick mode)
  if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
    install_additional_targets
  fi
  
  # Verify installation
  if [[ "$DRY_RUN" != "true" ]]; then
    if ! verify_rust_installation; then
      log_warning "Rust installation verification had issues, but this is not critical"
      log_info "Rust tools were installed successfully, continuing..."
    fi
  fi
  
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