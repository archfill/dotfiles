#!/usr/bin/env bash

# Go SDK installation script using g (Go version manager)
# This script installs g and the latest stable Go version

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Go SDK setup via g (Go version manager)..."

# Install g (Go version manager)
install_g() {
  log_info "Installing g (Go version manager)..."
  
  # Check if g is already installed
  if command -v g >/dev/null 2>&1; then
    log_success "g is already installed: $(g --version 2>/dev/null || echo 'version unknown')"
    return 0
  fi
  
  # Install g via curl
  local install_dir="$HOME/.g"
  local bin_dir="$HOME/.local/bin"
  
  # Create directories
  mkdir -p "$install_dir" "$bin_dir"
  
  # Download g
  log_info "Downloading g..."
  
  # Set required environment variables to avoid unbound variable errors
  export USER="${USER:-$(whoami)}"
  export HOME="${HOME:-$(getent passwd "$USER" | cut -d: -f6)}"
  
  # Install g with proper environment
  if curl -sSL https://git.io/g-install | USER="$USER" HOME="$HOME" SHELL="$SHELL" bash -s -- -y 2>/dev/null; then
    # Add to PATH for current session
    export PATH="$bin_dir:$PATH"
    
    if command -v g >/dev/null 2>&1; then
      log_success "g installed successfully"
      return 0
    else
      log_warning "g installation script completed but g command not found"
    fi
  else
    log_warning "g installation script failed"
  fi
  
  log_error "g installation failed"
  return 1
}

# Install latest stable Go version
install_go_latest() {
  log_info "Installing latest stable Go version..."
  
  # Ensure g is available
  if ! command -v g >/dev/null 2>&1; then
    # Try to source g environment
    if [[ -f "$HOME/.g/env" ]]; then
      source "$HOME/.g/env"
    fi
    
    if ! command -v g >/dev/null 2>&1; then
      log_error "g not found in PATH"
      exit 1
    fi
  fi
  
  # Check if Go is already installed
  if command -v go >/dev/null 2>&1; then
    local current_version=$(go version | awk '{print $3}' | sed 's/go//')
    log_info "Current Go version: $current_version"
    
    # Check if it's a recent version (1.21 or higher)
    local major_minor=$(echo "$current_version" | cut -d. -f1,2)
    if [[ "$major_minor" > "1.20" ]]; then
      log_success "Go $current_version is already installed and up to date"
      setup_go_environment
      return 0
    fi
  fi
  
  # Get latest Go version
  log_info "Fetching latest Go version..."
  local latest_version=$(g list-all | grep -E "^[0-9]+\.[0-9]+(\.[0-9]+)?$" | tail -1)
  
  if [[ -z "$latest_version" ]]; then
    log_warning "Could not determine latest version, installing default"
    latest_version="1.21.5"
  fi
  
  log_info "Installing Go $latest_version..."
  g install "$latest_version"
  
  # Set as current version
  g "$latest_version"
  
  # Verify installation
  verify_go_installation
}

# Setup Go environment
setup_go_environment() {
  log_info "Setting up Go environment..."
  
  # Set Go environment variables
  export GOPATH="${GOPATH:-$HOME/go}"
  export GOBIN="$GOPATH/bin"
  
  # Create Go workspace directories
  mkdir -p "$GOPATH/src" "$GOPATH/pkg" "$GOBIN"
  
  # Add Go binaries to PATH
  if [[ ":$PATH:" != *":$GOBIN:"* ]]; then
    export PATH="$GOBIN:$PATH"
  fi
  
  # Source g environment if available
  if [[ -f "$HOME/.g/env" ]]; then
    source "$HOME/.g/env"
  fi
  
  log_info "GOPATH: $GOPATH"
  log_info "GOBIN: $GOBIN"
  
  if command -v go >/dev/null 2>&1; then
    log_info "GOROOT: $(go env GOROOT)"
  fi
}

# Install useful Go tools
install_go_tools() {
  log_info "Installing useful Go tools..."
  
  # Ensure Go is available
  if ! command -v go >/dev/null 2>&1; then
    log_warning "Go not found in PATH, skipping tools installation"
    return 0
  fi
  
  # Ensure GOBIN is in PATH for current session
  if [[ -n "${GOBIN:-}" ]] && [[ ":$PATH:" != *":$GOBIN:"* ]]; then
    export PATH="$GOBIN:$PATH"
    log_info "Added GOBIN to PATH: $GOBIN"
  fi
  
  # Create a safe workspace for tools
  local tools_workspace="$HOME/tmp/go-tools-install"
  mkdir -p "$tools_workspace"
  local original_dir="$PWD"
  cd "$tools_workspace"
  
  # Initialize module in tools workspace
  if ! go mod init go-tools-install >/dev/null 2>&1; then
    log_warning "Failed to initialize Go module for tools installation"
    cd "$original_dir"
    rm -rf "$tools_workspace"
    return 0
  fi
  
  # List of essential Go tools only
  local tools=(
    "golang.org/x/tools/cmd/goimports@latest"    # goimports for import management
  )
  
  for tool in "${tools[@]}"; do
    local tool_name=$(basename "${tool%@*}")
    if ! command -v "$tool_name" >/dev/null 2>&1; then
      log_info "Installing $tool_name..."
      if go install "$tool" >/dev/null 2>&1; then
        log_info "$tool_name installed successfully"
      else
        log_warning "Failed to install $tool (this is not critical)"
      fi
    else
      log_info "$tool_name is already installed"
    fi
  done
  
  # Return to original directory and clean up
  cd "$original_dir"
  rm -rf "$tools_workspace"
  
  log_success "Go tools installation completed"
}

# Verify Go installation
verify_go_installation() {
  log_info "Verifying Go installation..."
  
  # Source environment if needed
  setup_go_environment
  
  if command -v go >/dev/null 2>&1; then
    log_success "Go installed successfully!"
    log_info "Go version: $(go version)"
    
    # Show Go environment
    log_info "Go environment:"
    go env GOROOT GOPATH GOBIN GOOS GOARCH
    
    # Test basic Go functionality
    log_info "Testing Go installation..."
    if go version >/dev/null 2>&1; then
      log_success "Go installation test passed"
    else
      log_warning "Go installation test failed"
    fi
  else
    log_error "Go installation verification failed"
    log_info "Please restart your shell and try again"
    exit 1
  fi
}

# Setup Go modules and workspace
setup_go_workspace() {
  log_info "Setting up Go workspace..."
  
  # Ensure GOPATH exists
  if [[ -n "$GOPATH" ]]; then
    mkdir -p "$GOPATH/src" "$GOPATH/pkg" "$GOPATH/bin"
    log_info "Go workspace created at: $GOPATH"
  fi
  
  # Test Go modules functionality
  if command -v go >/dev/null 2>&1; then
    local original_dir="$PWD"
    local test_dir="$HOME/tmp/go-test"
    
    # Clean up any existing test directory first
    rm -rf "$test_dir"
    
    # Create and test Go module
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    if go mod init test-module >/dev/null 2>&1 && [[ -f "go.mod" ]]; then
      log_success "Go modules working correctly"
    else
      log_warning "Go modules test failed (not critical)"
    fi
    
    # Return to original directory before cleanup
    cd "$original_dir"
    rm -rf "$test_dir"
  else
    log_warning "Go not available for modules test"
  fi
}

# Alternative: Install Go via official binary (fallback)
install_go_official() {
  log_info "Installing Go via official binary (fallback method)..."
  
  local platform
  platform=$(detect_platform)
  
  local arch
  case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) log_error "Unsupported architecture: $(uname -m)"; exit 1 ;;
  esac
  
  # Determine OS
  local os
  case "$platform" in
    macos) os="darwin" ;;
    linux) os="linux" ;;
    *) log_error "Unsupported platform: $platform"; exit 1 ;;
  esac
  
  # Get latest version from Go website
  local latest_version="1.21.5"  # Fallback version
  local download_url="https://go.dev/dl/go${latest_version}.${os}-${arch}.tar.gz"
  local install_dir="$HOME/.local"
  
  log_info "Downloading Go $latest_version for $os-$arch..."
  curl -L "$download_url" | tar -C "$install_dir" -xzf -
  
  # Setup environment
  export GOROOT="$install_dir/go"
  export PATH="$GOROOT/bin:$PATH"
  
  if command -v go >/dev/null 2>&1; then
    log_success "Go installed successfully via official binary"
    setup_go_environment
  else
    log_error "Go installation failed"
    exit 1
  fi
}

# Main installation function
main() {
  log_info "Go SDK Setup via g (Go Version Manager)"
  log_info "======================================="
  
  # Try to install g first
  if install_g; then
    # Install latest Go via g
    install_go_latest
  else
    log_warning "g installation failed, trying official binary..."
    install_go_official
  fi
  
  # Setup environment
  setup_go_environment
  
  # Setup workspace
  setup_go_workspace
  
  # Install useful tools
  install_go_tools
  
  log_success "Go SDK setup completed!"
  log_info ""
  log_info "Available g commands (if installed):"
  log_info "  g list              # List installed Go versions"
  log_info "  g list-all          # List all available versions"
  log_info "  g install <version> # Install specific Go version"
  log_info "  g <version>         # Switch to specific version"
  log_info "  g use <version>     # Use version for current session"
  log_info ""
  log_info "Go environment:"
  log_info "  go version          # Show Go version"
  log_info "  go env              # Show Go environment variables"
  log_info "  go mod init <name>  # Initialize new Go module"
  log_info ""
  log_info "Installed tools:"
  log_info "  goimports           # Import management"
  log_info "  golangci-lint       # Comprehensive linter"
  log_info "  staticcheck         # Static analysis"
  log_info "  dlv                 # Go debugger"
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"