#!/usr/bin/env bash

# Java SDK installation script using SDKMAN!
# This script installs SDKMAN! and Java 21 LTS

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

log_info "Starting Java SDK setup via SDKMAN!..."

# =============================================================================
# Enhanced SDKMAN! Environment Checking and Management Functions
# =============================================================================

# Check SDKMAN! installation and environment
check_sdkman_environment() {
    log_info "Checking SDKMAN! environment..."
    
    local all_checks_passed=true
    
    # Check SDKMAN! installation
    local sdkman_init="$HOME/.sdkman/bin/sdkman-init.sh"
    if [[ ! -s "$sdkman_init" ]]; then
        log_info "SDKMAN! not installed"
        all_checks_passed=false
    else
        log_info "SDKMAN! installation found: $sdkman_init"
        
        # Check SDKMAN! directory structure
        local sdkman_dir="${SDKMAN_DIR:-$HOME/.sdkman}"
        if [[ ! -d "$sdkman_dir/candidates" ]]; then
            log_warning "SDKMAN! candidates directory not found: $sdkman_dir/candidates"
        fi
    fi
    
    # Check sdk command availability (after sourcing)
    local temp_sdk_available=false
    if [[ -s "$sdkman_init" ]]; then
        # Temporarily source SDKMAN! to check sdk command
        (
            export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
            set +u
            source "$sdkman_init" >/dev/null 2>&1
            set -u
            command -v sdk >/dev/null 2>&1
        ) && temp_sdk_available=true
    fi
    
    if [[ "$temp_sdk_available" == "true" ]]; then
        log_info "sdk command available"
    else
        log_warning "sdk command not available"
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "SDKMAN! environment checks passed"
        return 0
    else
        log_info "SDKMAN! environment checks failed"
        return 1
    fi
}

# Check Java installation status
check_java_status() {
    log_info "Checking Java installation status..."
    
    # Check if Java is available via system PATH
    if command -v java >/dev/null 2>&1; then
        local java_version
        java_version=$(java -version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "unknown")
        log_info "System Java version: $java_version"
    else
        log_info "No system Java installation found"
    fi
    
    # Check SDKMAN! managed Java installations
    local sdkman_init="$HOME/.sdkman/bin/sdkman-init.sh"
    if [[ -s "$sdkman_init" ]]; then
        local java_installations
        java_installations=$(
            export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
            set +u
            source "$sdkman_init" >/dev/null 2>&1
            sdk list java 2>/dev/null | grep -c "installed" || echo 0
            set -u
        )
        log_info "SDKMAN! managed Java installations: $java_installations"
        
        # Check current SDKMAN! Java version
        local current_java
        current_java=$(
            export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
            set +u
            source "$sdkman_init" >/dev/null 2>&1
            sdk current java 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "none"
            set -u
        )
        
        if [[ "$current_java" != "none" ]]; then
            log_info "Current SDKMAN! Java: $current_java"
        fi
    fi
    
    log_success "Java status check completed"
    return 0
}

# Check build tools status
check_build_tools_status() {
    log_info "Checking Java build tools status..."
    
    local tools_info=(
        "maven:mvn:Build automation tool"
        "gradle:gradle:Build automation tool"
    )
    
    local installed_tools=0
    for tool_info in "${tools_info[@]}"; do
        local tool_name=$(echo "$tool_info" | cut -d: -f1)
        local tool_cmd=$(echo "$tool_info" | cut -d: -f2)
        local tool_desc=$(echo "$tool_info" | cut -d: -f3)
        
        if command -v "$tool_cmd" >/dev/null 2>&1; then
            local tool_version
            case "$tool_cmd" in
                mvn)
                    tool_version=$(mvn -version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
                    ;;
                gradle)
                    tool_version=$(gradle -version 2>/dev/null | grep 'Gradle' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
                    ;;
                *)
                    tool_version="unknown"
                    ;;
            esac
            log_info "$tool_name: $tool_version"
            ((installed_tools++))
        else
            log_info "$tool_name: not installed"
        fi
    done
    
    log_info "Installed build tools: $installed_tools/${#tools_info[@]}"
    log_success "Build tools status check completed"
    return 0
}

# Comprehensive SDKMAN! environment check
check_sdkman_comprehensive_environment() {
    log_info "Performing comprehensive SDKMAN! environment check..."
    
    local all_checks_passed=true
    
    # Check SDKMAN! installation
    if ! check_sdkman_environment; then
        all_checks_passed=false
    fi
    
    # Check Java status
    check_java_status
    
    # Check build tools status
    check_build_tools_status
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All SDKMAN! environment checks passed"
        return 0
    else
        log_info "Some SDKMAN! environment checks failed"
        return 1
    fi
}

# Install SDKMAN! with enhanced options
install_sdkman() {
  log_info "Installing SDKMAN!..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if SDKMAN! should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log_skip_reason "SDKMAN!" "Already installed"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install SDKMAN!"
    return 0
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
    # Download and install SDKMAN!
    curl -s "https://get.sdkman.io" | bash
  else
    log_info "[DRY RUN] Would download and install SDKMAN!"
  fi
  
  # Source SDKMAN! for immediate use with safe environment
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    # Set required environment variables before sourcing
    export SDKMAN_CANDIDATES_API="${SDKMAN_CANDIDATES_API:-https://api.sdkman.io/2}"
    export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
    export ZSH_VERSION="${ZSH_VERSION:-}"
    export BASH_VERSION="${BASH_VERSION:-$BASH_VERSION}"
    export SDKMAN_OFFLINE_MODE="${SDKMAN_OFFLINE_MODE:-false}"
    export SDKMAN_AUTO_ANSWER="${SDKMAN_AUTO_ANSWER:-false}"
    export SDKMAN_AUTO_SELFUPDATE="${SDKMAN_AUTO_SELFUPDATE:-false}"
    
    # Disable unbound variable checking for SDKMAN initialization
    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    set -u
  fi
  
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log_success "SDKMAN! installed successfully"
  else
    log_error "SDKMAN! installation failed"
    return 1
  fi
}

# Install Java 21 LTS with enhanced options
install_java_lts() {
  log_info "Installing Java 21 LTS..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Java 21 LTS"
    return 0
  fi
  
  # Source SDKMAN! with safe initialization
  if ! command -v sdk >/dev/null 2>&1; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      # Set all required environment variables before sourcing
      export SDKMAN_CANDIDATES_API="${SDKMAN_CANDIDATES_API:-https://api.sdkman.io/2}"
      export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
      export ZSH_VERSION="${ZSH_VERSION:-}"
      export BASH_VERSION="${BASH_VERSION:-$BASH_VERSION}"
      export SDKMAN_OFFLINE_MODE="${SDKMAN_OFFLINE_MODE:-false}"
      export SDKMAN_AUTO_ANSWER="${SDKMAN_AUTO_ANSWER:-false}"
      export SDKMAN_AUTO_SELFUPDATE="${SDKMAN_AUTO_SELFUPDATE:-false}"
      
      # Set script debugging to false to avoid unbound variable errors
      set +u
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      set -u
    else
      log_error "SDKMAN! not found"
      return 1
    fi
  fi
  
  # Check current Java version
  local current_java=$(sdk current java 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+[^[:space:]]*' || echo "none")
  if [[ "$FORCE_INSTALL" != "true" ]] && [[ "$current_java" != "none" && "$current_java" =~ ^21\. ]]; then
    log_skip_reason "Java 21 LTS" "Already installed: $current_java"
    return 0
  fi
  
  # List available Java 21 versions and select LTS
  log_info "Fetching available Java 21 LTS versions..."
  
  # Install latest Java 21 LTS (Temurin/Eclipse Adoptium)
  local java_version="21.0.5-tem"
  
  if [[ "$DRY_RUN" != "true" ]]; then
    log_info "Installing Java $java_version..."
    # Use SDKMAN_AUTO_ANSWER=true for non-interactive installation and disable unbound variable checking
    set +u
    SDKMAN_AUTO_ANSWER=true sdk install java "$java_version" || {
      log_error "Failed to install Java $java_version"
      set -u
      return 1
    }
    set -u
    
    # Set as default
    log_info "Setting Java $java_version as default..."
    set +u
    SDKMAN_AUTO_ANSWER=true sdk default java "$java_version" || {
      log_warning "Failed to set Java $java_version as default"
    }
    set -u
  else
    log_info "[DRY RUN] Would install Java $java_version"
  fi
  
  # Verify installation
  verify_java_installation
}

# Verify Java installation
verify_java_installation() {
  log_info "Verifying Java installation..."
  
  # Source SDKMAN! to ensure java command is available
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    # Set required environment variables before sourcing
    export SDKMAN_CANDIDATES_API="${SDKMAN_CANDIDATES_API:-https://api.sdkman.io/2}"
    export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
    export ZSH_VERSION="${ZSH_VERSION:-}"
    export BASH_VERSION="${BASH_VERSION:-$BASH_VERSION}"
    export SDKMAN_OFFLINE_MODE="${SDKMAN_OFFLINE_MODE:-false}"
    export SDKMAN_AUTO_ANSWER="${SDKMAN_AUTO_ANSWER:-false}"
    export SDKMAN_AUTO_SELFUPDATE="${SDKMAN_AUTO_SELFUPDATE:-false}"
    
    # Disable unbound variable checking for SDKMAN initialization
    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    set -u
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
    return 1
  fi
}

# Setup Java environment for current shell
setup_java_environment() {
  log_info "Setting up Java environment..."
  
  # Source SDKMAN! in current shell
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    # Set required environment variables before sourcing
    export SDKMAN_CANDIDATES_API="${SDKMAN_CANDIDATES_API:-https://api.sdkman.io/2}"
    export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
    export ZSH_VERSION="${ZSH_VERSION:-}"
    export BASH_VERSION="${BASH_VERSION:-$BASH_VERSION}"
    export SDKMAN_OFFLINE_MODE="${SDKMAN_OFFLINE_MODE:-false}"
    export SDKMAN_AUTO_ANSWER="${SDKMAN_AUTO_ANSWER:-false}"
    export SDKMAN_AUTO_SELFUPDATE="${SDKMAN_AUTO_SELFUPDATE:-false}"
    
    # Disable unbound variable checking for SDKMAN initialization
    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    set -u
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

# Install Maven (optional build tool) with enhanced options
install_maven() {
  log_info "Installing Maven..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if Maven should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v mvn >/dev/null 2>&1; then
    log_skip_reason "Maven" "Already installed: $(mvn -version 2>/dev/null | head -1)"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Maven"
    return 0
  fi
  
  # Source SDKMAN! if not already sourced
  if ! command -v sdk >/dev/null 2>&1; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      # Set required environment variables before sourcing
      export SDKMAN_CANDIDATES_API="${SDKMAN_CANDIDATES_API:-https://api.sdkman.io/2}"
      export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
      export ZSH_VERSION="${ZSH_VERSION:-}"
      export BASH_VERSION="${BASH_VERSION:-$BASH_VERSION}"
      export SDKMAN_OFFLINE_MODE="${SDKMAN_OFFLINE_MODE:-false}"
      export SDKMAN_AUTO_ANSWER="${SDKMAN_AUTO_ANSWER:-false}"
      export SDKMAN_AUTO_SELFUPDATE="${SDKMAN_AUTO_SELFUPDATE:-false}"
      
      # Disable unbound variable checking for SDKMAN initialization
      set +u
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      set -u
    fi
  fi
  
  if ! command -v sdk >/dev/null 2>&1; then
    log_warning "SDKMAN! not available, skipping Maven installation"
    return 1
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
    # Install latest Maven
    set +u
    SDKMAN_AUTO_ANSWER=true sdk install maven
    set -u
    
    if command -v mvn >/dev/null 2>&1; then
      log_success "Maven installed successfully: $(mvn -version | head -1)"
    else
      log_warning "Maven installation may have failed"
    fi
  else
    log_info "[DRY RUN] Would install Maven"
  fi
}

# Install Gradle (optional build tool) with enhanced options
install_gradle() {
  log_info "Installing Gradle..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if Gradle should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v gradle >/dev/null 2>&1; then
    log_skip_reason "Gradle" "Already installed: $(gradle -version 2>/dev/null | grep 'Gradle')"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Gradle"
    return 0
  fi
  
  # Source SDKMAN! if not already sourced
  if ! command -v sdk >/dev/null 2>&1; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      # Set required environment variables before sourcing
      export SDKMAN_CANDIDATES_API="${SDKMAN_CANDIDATES_API:-https://api.sdkman.io/2}"
      export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
      export ZSH_VERSION="${ZSH_VERSION:-}"
      export BASH_VERSION="${BASH_VERSION:-$BASH_VERSION}"
      export SDKMAN_OFFLINE_MODE="${SDKMAN_OFFLINE_MODE:-false}"
      export SDKMAN_AUTO_ANSWER="${SDKMAN_AUTO_ANSWER:-false}"
      export SDKMAN_AUTO_SELFUPDATE="${SDKMAN_AUTO_SELFUPDATE:-false}"
      
      # Disable unbound variable checking for SDKMAN initialization
      set +u
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      set -u
    fi
  fi
  
  if ! command -v sdk >/dev/null 2>&1; then
    log_warning "SDKMAN! not available, skipping Gradle installation"
    return 1
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
    # Install latest Gradle
    set +u
    SDKMAN_AUTO_ANSWER=true sdk install gradle
    set -u
    
    if command -v gradle >/dev/null 2>&1; then
      log_success "Gradle installed successfully: $(gradle -version | grep 'Gradle')"
    else
      log_warning "Gradle installation may have failed"
    fi
  else
    log_info "[DRY RUN] Would install Gradle"
  fi
}

# Main installation function
main() {
  log_info "Java SDK Setup via SDKMAN!"
  log_info "=========================="
  
  # Parse command line options
  parse_install_options "$@"
  
  # Get target Java version
  local java_version="${JAVA_VERSION:-21}"
  
  # Check if Java installation should be skipped
  if should_skip_installation_advanced "Java" "java" "$java_version" "-version"; then
    # Even if Java is installed, check and update environment
    log_info "Java is installed, checking SDKMAN! environment and build tools..."
    
    # Perform comprehensive environment check
    check_sdkman_comprehensive_environment
    
    # Setup/verify environment
    setup_java_environment
    
    # Install build tools
    install_maven "$@"
    install_gradle "$@"
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
      verify_java_installation
    fi
    
    return 0
  fi
  
  # Install SDKMAN!
  install_sdkman "$@"
  
  # Install Java 21 LTS
  install_java_lts "$@"
  
  # Setup environment
  setup_java_environment
  
  # Install build tools
  install_maven "$@"
  install_gradle "$@"
  
  # Verify installation
  if [[ "$DRY_RUN" != "true" ]]; then
    verify_java_installation
  fi
  
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