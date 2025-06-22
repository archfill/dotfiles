#!/usr/bin/env bash

# Java SDK installation script using SDKMAN!
# This script installs SDKMAN! and Java 21 LTS

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Java SDK setup via SDKMAN!..."

# Install SDKMAN!
install_sdkman() {
  log_info "Installing SDKMAN!..."
  
  # Check if SDKMAN! is already installed
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log_success "SDKMAN! is already installed"
    return 0
  fi
  
  # Download and install SDKMAN!
  curl -s "https://get.sdkman.io" | bash
  
  # Source SDKMAN! for immediate use
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log_success "SDKMAN! installed successfully"
  else
    log_error "SDKMAN! installation failed"
    exit 1
  fi
}

# Install Java 21 LTS
install_java_lts() {
  log_info "Installing Java 21 LTS..."
  
  # Source SDKMAN! if not already sourced
  if ! command -v sdk >/dev/null 2>&1; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
      log_error "SDKMAN! not found"
      exit 1
    fi
  fi
  
  # Check current Java version
  local current_java=$(sdk current java 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+[^[:space:]]*' || echo "none")
  if [[ "$current_java" != "none" && "$current_java" =~ ^21\. ]]; then
    log_success "Java 21 LTS is already installed: $current_java"
    return 0
  fi
  
  # List available Java 21 versions and select LTS
  log_info "Fetching available Java 21 LTS versions..."
  
  # Install latest Java 21 LTS (Temurin/Eclipse Adoptium)
  local java_version="21.0.1-tem"
  
  log_info "Installing Java $java_version..."
  sdk install java "$java_version"
  
  # Set as default
  log_info "Setting Java $java_version as default..."
  sdk default java "$java_version"
  
  # Verify installation
  verify_java_installation
}

# Verify Java installation
verify_java_installation() {
  log_info "Verifying Java installation..."
  
  # Source SDKMAN! to ensure java command is available
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  fi
  
  if command -v java >/dev/null 2>&1; then
    local java_version=$(java -version 2>&1 | head -1)
    log_success "Java installed successfully!"
    log_info "Java version: $java_version"
    
    # Show JAVA_HOME
    if [[ -n "${JAVA_HOME:-}" ]]; then
      log_info "JAVA_HOME: $JAVA_HOME"
    fi
    
    # List installed Java versions
    log_info "Installed Java versions:"
    sdk list java | grep installed || log_info "No other Java versions installed"
  else
    log_error "Java installation verification failed"
    log_info "Please restart your shell and try again"
    exit 1
  fi
}

# Setup Java environment for current shell
setup_java_environment() {
  log_info "Setting up Java environment..."
  
  # Source SDKMAN! in current shell
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    log_success "SDKMAN! environment loaded"
  fi
  
  # Ensure JAVA_HOME is set
  if [[ -z "${JAVA_HOME:-}" ]] && command -v sdk >/dev/null 2>&1; then
    export JAVA_HOME="$(sdk home java current 2>/dev/null || echo '')"
    if [[ -n "$JAVA_HOME" ]]; then
      log_info "JAVA_HOME set to: $JAVA_HOME"
    fi
  fi
}

# Install Maven (optional build tool)
install_maven() {
  log_info "Installing Maven..."
  
  # Source SDKMAN! if not already sourced
  if ! command -v sdk >/dev/null 2>&1; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
  fi
  
  # Check if Maven is already installed
  if command -v mvn >/dev/null 2>&1; then
    log_success "Maven is already installed: $(mvn -version | head -1)"
    return 0
  fi
  
  # Install latest Maven
  sdk install maven
  
  if command -v mvn >/dev/null 2>&1; then
    log_success "Maven installed successfully: $(mvn -version | head -1)"
  else
    log_warning "Maven installation may have failed"
  fi
}

# Install Gradle (optional build tool)
install_gradle() {
  log_info "Installing Gradle..."
  
  # Source SDKMAN! if not already sourced
  if ! command -v sdk >/dev/null 2>&1; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
  fi
  
  # Check if Gradle is already installed
  if command -v gradle >/dev/null 2>&1; then
    log_success "Gradle is already installed: $(gradle -version | grep 'Gradle')"
    return 0
  fi
  
  # Install latest Gradle
  sdk install gradle
  
  if command -v gradle >/dev/null 2>&1; then
    log_success "Gradle installed successfully: $(gradle -version | grep 'Gradle')"
  else
    log_warning "Gradle installation may have failed"
  fi
}

# Main installation function
main() {
  log_info "Java SDK Setup via SDKMAN!"
  log_info "=========================="
  
  # Install SDKMAN!
  install_sdkman
  
  # Install Java 21 LTS
  install_java_lts
  
  # Setup environment
  setup_java_environment
  
  # Install build tools
  install_maven
  install_gradle
  
  log_success "Java SDK setup completed!"
  log_info ""
  log_info "Available SDKMAN! commands:"
  log_info "  sdk list java          # List available Java versions"
  log_info "  sdk install java <ver> # Install specific Java version"
  log_info "  sdk use java <ver>      # Use Java version for current shell"
  log_info "  sdk default java <ver> # Set default Java version"
  log_info "  sdk current java       # Show current Java version"
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"