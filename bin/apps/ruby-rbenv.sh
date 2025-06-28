#!/usr/bin/env bash

# Ruby SDK installation script using rbenv
# This script installs rbenv and Ruby LTS version with automatic LTS detection

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

log_info "Starting Ruby SDK setup via rbenv..."

# =============================================================================
# Enhanced Ruby/Gem Management and Checking Functions
# =============================================================================

# Check rbenv installation and configuration
check_rbenv_environment() {
    log_info "Checking rbenv environment..."
    
    local all_checks_passed=true
    
    # Check rbenv command availability
    if ! is_command_available "rbenv" "--version"; then
        log_info "rbenv not available"
        all_checks_passed=false
    else
        # Check rbenv configuration
        if [[ ":$PATH:" != *":$HOME/.rbenv/bin:"* ]]; then
            log_warning "rbenv not in PATH, may need shell profile update"
        fi
        
        # Check rbenv root
        local rbenv_root="${RBENV_ROOT:-$HOME/.rbenv}"
        if [[ ! -d "$rbenv_root" ]]; then
            log_warning "rbenv root directory not found: $rbenv_root"
            all_checks_passed=false
        fi
        
        # Check ruby-build plugin
        if [[ ! -d "$rbenv_root/plugins/ruby-build" ]]; then
            log_warning "ruby-build plugin not found"
            all_checks_passed=false
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "rbenv environment checks passed"
        return 0
    else
        log_info "rbenv environment checks failed"
        return 1
    fi
}

# Check Ruby version requirements
check_ruby_version_requirements() {
    local required_version="${RUBY_VERSION:-3.3.0}"
    
    # Handle 'lts' version specification
    if [[ "$required_version" == "lts" ]]; then
        required_version=$(get_ruby_lts_version)
    fi
    
    log_info "Checking Ruby version requirements (>= $required_version)..."
    
    if ! command -v ruby >/dev/null 2>&1; then
        log_info "Ruby command not available"
        return 1
    fi
    
    # Ruby version output format: "ruby 3.3.6 (2024-11-05 revision abc123) [x86_64-linux]"
    local current_version
    current_version=$(ruby --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine Ruby version"
        return 1
    fi
    
    compare_versions "$current_version" "$required_version"
    local result=$?
    
    case $result in
        0|2)  # current >= required
            log_success "Ruby version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "Ruby version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for Ruby"
            return 1
            ;;
    esac
}

# Check essential gem availability and versions
check_essential_gems() {
    log_info "Checking essential Ruby gems..."
    
    if ! command -v gem >/dev/null 2>&1; then
        log_info "gem command not available"
        return 1
    fi
    
    local essential_gems=(
        "bundler:2.0.0"
        "rake:13.0.0"
        "rubocop:1.0.0"
    )
    
    local all_gems_satisfied=true
    
    for gem_spec in "${essential_gems[@]}"; do
        local gem_name=$(echo "$gem_spec" | cut -d: -f1)
        local min_version=$(echo "$gem_spec" | cut -d: -f2)
        
        if gem list "$gem_name" -i >/dev/null 2>&1; then
            local current_version
            current_version=$(gem list "$gem_name" --exact 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            
            if [[ -n "$current_version" ]]; then
                compare_versions "$current_version" "$min_version"
                case $? in
                    0|2)  # current >= required
                        log_info "Gem $gem_name satisfied: $current_version >= $min_version"
                        ;;
                    1)    # current < required
                        log_info "Gem $gem_name needs update: $current_version < $min_version"
                        all_gems_satisfied=false
                        ;;
                    *)
                        log_warning "Version comparison failed for gem $gem_name"
                        all_gems_satisfied=false
                        ;;
                esac
            else
                log_info "Gem $gem_name version could not be determined"
                all_gems_satisfied=false
            fi
        else
            log_info "Essential gem not installed: $gem_name"
            all_gems_satisfied=false
        fi
    done
    
    if [[ "$all_gems_satisfied" == "true" ]]; then
        log_success "All essential gems are available and up to date"
        return 0
    else
        log_info "Some essential gems need installation or updates"
        return 1
    fi
}

# Check Ruby project and dependency management
check_ruby_project_management() {
    log_info "Checking Ruby project management capabilities..."
    
    # Check bundler functionality
    if command -v bundle >/dev/null 2>&1; then
        log_info "Bundler version: $(bundle --version 2>/dev/null || echo 'unknown')"
        
        # Test bundler in a temporary environment
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        cat > Gemfile << 'EOF'
source 'https://rubygems.org'
gem 'json'
EOF
        
        if bundle check --dry-run >/dev/null 2>&1; then
            log_success "Bundler dependency resolution working"
        else
            log_info "Bundler needs gem installation for dependency resolution"
        fi
        
        cd - >/dev/null
        rm -rf "$temp_dir"
    else
        log_warning "Bundler not available"
        return 1
    fi
    
    # Check rbenv functionality
    if command -v rbenv >/dev/null 2>&1; then
        local available_versions
        available_versions=$(rbenv versions 2>/dev/null | wc -l || echo 0)
        log_info "Available Ruby versions via rbenv: $available_versions"
        
        local global_version
        global_version=$(rbenv global 2>/dev/null || echo "not set")
        log_info "Global Ruby version: $global_version"
    fi
    
    log_success "Ruby project management check completed"
    return 0
}

# Comprehensive Ruby environment check
check_ruby_environment() {
    log_info "Performing comprehensive Ruby environment check..."
    
    local all_checks_passed=true
    
    # Check rbenv environment
    if ! check_rbenv_environment; then
        all_checks_passed=false
    fi
    
    # Check Ruby version requirements
    if ! check_ruby_version_requirements; then
        all_checks_passed=false
    fi
    
    # Check essential gems
    if ! check_essential_gems; then
        log_info "Essential gems need installation or updates"
        all_checks_passed=false
    fi
    
    # Check project management capabilities
    check_ruby_project_management
    
    # Check PATH configuration
    if ! command -v ruby >/dev/null 2>&1; then
        log_warning "Ruby not found in PATH"
        all_checks_passed=false
        
        # Check if Ruby exists in rbenv directories
        local rbenv_root="${RBENV_ROOT:-$HOME/.rbenv}"
        if [[ -d "$rbenv_root/shims" ]]; then
            log_info "Found rbenv shims directory: $rbenv_root/shims"
            if [[ -x "$rbenv_root/shims/ruby" ]]; then
                log_info "Ruby shim found at: $rbenv_root/shims/ruby"
            fi
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All Ruby environment checks passed"
        return 0
    else
        log_info "Some Ruby environment checks failed"
        return 1
    fi
}

# Check and setup sudo access for dependency installation
check_sudo_access() {
  log_info "Checking sudo access for dependency installation..."
  
  # Check if sudo is available
  if ! command -v sudo >/dev/null 2>&1; then
    log_error "sudo is not available on this system"
    log_info "Please install dependencies manually or run as root"
    exit 1
  fi
  
  # Check if user is already root
  if [[ $EUID -eq 0 ]]; then
    log_info "Running as root, no sudo authentication required"
    return 0
  fi
  
  # Check if sudo is configured to not require password
  if sudo -n true 2>/dev/null; then
    log_success "sudo access confirmed (no password required)"
    return 0
  fi
  
  # Prompt for sudo password
  log_info "This script requires sudo access to install Ruby build dependencies"
  log_info "You will be prompted for your password to install system packages"
  
  # Use sudo -v to validate and cache credentials
  if sudo -v; then
    log_success "sudo access confirmed"
    
    # Keep sudo session alive in background
    # This prevents timeout during long operations
    (
      while true; do
        sleep 60
        sudo -n true 2>/dev/null || break
      done
    ) &
    local sudo_keeper_pid=$!
    
    # Store PID for cleanup
    echo $sudo_keeper_pid > /tmp/ruby-setup-sudo-keeper.pid
    
    return 0
  else
    log_error "sudo authentication failed"
    log_info "Please ensure you have sudo privileges or run the script with appropriate permissions"
    exit 1
  fi
}

# Cleanup sudo keeper process
cleanup_sudo_keeper() {
  if [[ -f /tmp/ruby-setup-sudo-keeper.pid ]]; then
    local pid=$(cat /tmp/ruby-setup-sudo-keeper.pid)
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null
    fi
    rm -f /tmp/ruby-setup-sudo-keeper.pid
  fi
}

# Get Ruby LTS version with automatic detection
get_ruby_lts_version() {
  # Check versions.conf setting
  if [[ "${RUBY_VERSION:-}" == "lts" ]]; then
    # Try to get latest 3.3.x version from GitHub API
    local latest_version
    latest_version=$(curl -s --connect-timeout 10 "https://api.github.com/repos/ruby/ruby/releases" 2>/dev/null | \
      grep -o '"tag_name": "v[0-9]*\.[0-9]*\.[0-9]*"' | \
      grep -o 'v3\.3\.[0-9]*' | \
      sort -V | tail -1 | sed 's/v//' 2>/dev/null)
    
    if [[ -n "$latest_version" ]]; then
      echo "$latest_version"
    else
      # Fallback to known stable version
      echo "3.3.6"
    fi
  else
    # Use explicitly specified version
    echo "${RUBY_VERSION:-3.3.6}"
  fi
}

# Install platform-specific Ruby build dependencies
install_ruby_dependencies() {
  log_info "Installing Ruby build dependencies..."
  
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    linux)
      if ! install_linux_ruby_deps; then
        log_error "Failed to install Linux Ruby dependencies"
        cleanup_sudo_keeper
        exit 1
      fi
      ;;
    macos)
      if ! install_macos_ruby_deps; then
        log_error "Failed to install macOS Ruby dependencies"
        exit 1
      fi
      ;;
    *)
      log_warning "Platform $platform may not be fully supported"
      log_info "Please install Ruby build dependencies manually"
      ;;
  esac
}

# Install Ruby dependencies on Linux
install_linux_ruby_deps() {
  log_info "Installing Linux Ruby build dependencies..."
  
  local distro
  distro=$(get_os_distribution)
  
  case "$distro" in
    debian|ubuntu)
      log_info "Updating package lists..."
      if ! sudo apt update; then
        log_error "Failed to update package lists"
        return 1
      fi
      
      log_info "Installing Ruby build dependencies for Debian/Ubuntu..."
      if ! sudo apt install -y \
        git curl \
        libssl-dev libreadline-dev zlib1g-dev \
        libyaml-dev libxml2-dev libxslt1-dev \
        libffi-dev build-essential \
        autoconf bison; then
        log_error "Failed to install Ruby dependencies"
        return 1
      fi
      ;;
    arch)
      log_info "Installing Ruby build dependencies for Arch Linux..."
      if ! sudo pacman -Syu --needed --noconfirm \
        base-devel \
        openssl readline zlib \
        yaml libxml2 libxslt \
        libffi autoconf bison; then
        log_error "Failed to install Ruby dependencies"
        return 1
      fi
      ;;
    fedora|centos|rhel)
      log_info "Installing development tools..."
      if ! sudo yum groupinstall -y "Development Tools"; then
        log_error "Failed to install development tools"
        return 1
      fi
      
      log_info "Installing Ruby build dependencies for RHEL/Fedora..."
      if ! sudo yum install -y \
        git curl \
        openssl-devel readline-devel zlib-devel \
        libyaml-devel libxml2-devel libxslt-devel \
        libffi-devel autoconf bison; then
        log_error "Failed to install Ruby dependencies"
        return 1
      fi
      ;;
    *)
      log_warning "Unknown Linux distribution: $distro"
      log_info "Please install Ruby build dependencies manually"
      log_info "Required packages: git, curl, build tools, openssl, readline, zlib, yaml, libxml2, libxslt, libffi, autoconf, bison"
      return 1
      ;;
  esac
  
  log_success "Ruby build dependencies installed successfully"
}

# Install Ruby dependencies on macOS
install_macos_ruby_deps() {
  log_info "Installing macOS Ruby build dependencies..."
  
  # Check if Homebrew is installed
  if ! command -v brew >/dev/null 2>&1; then
    log_error "Homebrew is required but not installed"
    log_info "Please install Homebrew first: https://brew.sh"
    exit 1
  fi
  
  # Install dependencies via Homebrew
  brew install \
    openssl readline libyaml libffi \
    autoconf bison
  
  log_success "macOS Ruby dependencies installed"
}

# Install rbenv
install_rbenv() {
  log_info "Installing rbenv..."
  
  # Check if rbenv is already installed
  if command -v rbenv >/dev/null 2>&1; then
    log_success "rbenv is already installed: $(rbenv --version)"
    return 0
  fi
  
  # Install rbenv via git
  local rbenv_dir="$HOME/.rbenv"
  
  if [[ -d "$rbenv_dir" ]]; then
    log_info "rbenv directory exists, updating..."
    cd "$rbenv_dir" && git pull
  else
    log_info "Cloning rbenv..."
    git clone https://github.com/rbenv/rbenv.git "$rbenv_dir"
  fi
  
  # Add rbenv to PATH for current session
  export PATH="$rbenv_dir/bin:$PATH"
  
  # Initialize rbenv
  eval "$(rbenv init -)"
  
  if command -v rbenv >/dev/null 2>&1; then
    log_success "rbenv installed successfully"
  else
    log_error "rbenv installation failed"
    exit 1
  fi
}

# Install ruby-build plugin
install_ruby_build() {
  log_info "Installing ruby-build plugin..."
  
  local ruby_build_dir="$HOME/.rbenv/plugins/ruby-build"
  
  if [[ -d "$ruby_build_dir" ]]; then
    log_info "ruby-build already exists, updating..."
    cd "$ruby_build_dir" && git pull
  else
    log_info "Cloning ruby-build..."
    git clone https://github.com/rbenv/ruby-build.git "$ruby_build_dir"
  fi
  
  log_success "ruby-build plugin installed"
}

# Install specified Ruby version
install_ruby_version() {
  local ruby_version="$1"
  
  log_info "Installing Ruby $ruby_version..."
  
  # Ensure rbenv is available
  if ! command -v rbenv >/dev/null 2>&1; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
  
  # Check if this version is already installed
  if rbenv versions | grep -q "$ruby_version"; then
    log_success "Ruby $ruby_version is already installed"
    rbenv global "$ruby_version"
    return 0
  fi
  
  # Install Ruby version
  log_info "This may take several minutes..."
  if rbenv install "$ruby_version"; then
    log_success "Ruby $ruby_version installed successfully"
    
    # Set as global version
    rbenv global "$ruby_version"
    
    # Rehash to update shims
    rbenv rehash
  else
    log_error "Ruby $ruby_version installation failed"
    exit 1
  fi
}

# Enhanced function to install essential Ruby gems
install_ruby_tools() {
  log_info "Installing essential Ruby gems..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Ensure rbenv environment is properly set up
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  export PATH="$HOME/.rbenv/shims:$PATH"
  
  # Verify Ruby and gem are available
  if ! command -v ruby >/dev/null 2>&1; then
    log_error "Ruby command not found after rbenv setup"
    log_info "Current PATH: $PATH"
    log_info "Available rbenv versions:"
    rbenv versions || log_warning "rbenv versions command failed"
    return 1
  fi
  
  if ! command -v gem >/dev/null 2>&1; then
    log_error "gem command not found after rbenv setup"
    log_info "Ruby location: $(which ruby)"
    log_info "Expected gem location: $(dirname "$(which ruby)")/gem"
    return 1
  fi
  
  log_info "Ruby version: $(ruby --version)"
  log_info "Gem version: $(gem --version)"
  log_info "Ruby location: $(which ruby)"
  log_info "Gem location: $(which gem)"
  
  # List of essential gems with minimum versions
  local gems_info=(
    "bundler:2.0.0:Dependency management for Ruby projects"
    "rake:13.0.0:Build automation tool for Ruby"
    "rubocop:1.0.0:Code linter and formatter"
    "solargraph:0.40.0:Language server for IDE support"
    "pry:0.13.0:Interactive debugging console"
  )
  
  local installed_count=0
  local skipped_count=0
  local failed_count=0
  
  for gem_info in "${gems_info[@]}"; do
    local gem_name=$(echo "$gem_info" | cut -d: -f1)
    local min_version=$(echo "$gem_info" | cut -d: -f2)
    local gem_desc=$(echo "$gem_info" | cut -d: -f3)
    
    # Skip if gem meets version requirements and not forcing reinstall
    if [[ "$FORCE_INSTALL" != "true" ]] && gem list "$gem_name" -i >/dev/null 2>&1; then
      local current_version
      current_version=$(gem list "$gem_name" --exact 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
      
      if [[ -n "$current_version" ]]; then
        compare_versions "$current_version" "$min_version"
        case $? in
          0|2)  # current >= required
            log_skip_reason "$gem_name" "Already installed with sufficient version: $current_version >= $min_version"
            ((skipped_count++))
            continue
            ;;
        esac
      fi
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
      log_info "QUICK: Would install gem $gem_name ($gem_desc)"
      continue
    fi
    
    # Install the gem
    log_info "Installing gem: $gem_name ($gem_desc)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "[DRY RUN] Would execute: gem install $gem_name --no-document"
      ((installed_count++))
    else
      if gem install "$gem_name" --no-document; then
        log_success "Successfully installed gem: $gem_name"
        ((installed_count++))
      else
        log_error "Failed to install gem: $gem_name"
        ((failed_count++))
      fi
    fi
  done
  
  # Log summary
  if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
    log_install_summary "$installed_count" "$skipped_count" "$failed_count"
  fi
  
  # Rehash after gem installation to update shims
  if [[ "$DRY_RUN" != "true" && "$installed_count" -gt 0 ]]; then
    log_info "Updating rbenv shims..."
    rbenv rehash
  fi
  
  log_success "Essential Ruby gems installation completed"
}

# Setup Ruby environment
setup_ruby_environment() {
  log_info "Setting up Ruby environment..."
  
  # Add rbenv to PATH and init for current session
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  export PATH="$HOME/.rbenv/shims:$PATH"
  
  # Set environment variables
  export RBENV_ROOT="${RBENV_ROOT:-$HOME/.rbenv}"
  
  log_info "RBENV_ROOT: $RBENV_ROOT"
  log_info "Current PATH: $PATH"
  
  # Verify rbenv is working
  if command -v rbenv >/dev/null 2>&1; then
    log_info "rbenv is available: $(rbenv --version)"
    log_info "Active Ruby version: $(rbenv version)"
  else
    log_error "rbenv command not found in PATH"
    return 1
  fi
  
  # Force rehash to ensure shims are updated
  rbenv rehash
  
  if command -v ruby >/dev/null 2>&1; then
    log_info "Current Ruby: $(ruby --version)"
    log_info "Ruby location: $(which ruby)"
    
    if command -v gem >/dev/null 2>&1; then
      log_info "Gem location: $(which gem)"
      log_info "Gem environment: $(gem env gemdir)"
    else
      log_warning "gem command not found, but Ruby is available"
    fi
  else
    log_warning "Ruby command not found after environment setup"
  fi
}

# Verify Ruby installation
verify_ruby_installation() {
  log_info "Verifying Ruby installation..."
  
  # Setup environment if needed
  setup_ruby_environment
  
  if command -v ruby >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
    log_success "Ruby installed successfully!"
    log_info "Ruby version: $(ruby --version)"
    log_info "Gem version: $(gem --version)"
    log_info "Bundler version: $(bundle --version 2>/dev/null || echo 'not installed')"
    
    # Show rbenv info
    if command -v rbenv >/dev/null 2>&1; then
      log_info "rbenv version: $(rbenv --version)"
      log_info "Available Ruby versions:"
      rbenv versions
      log_info "Global Ruby version: $(rbenv global)"
    fi
    
    # Show gem environment
    log_info "Gem environment:"
    gem env gemdir
    
    # Test basic Ruby functionality
    log_info "Testing Ruby installation..."
    if ruby -e "puts 'Ruby is working!'" >/dev/null 2>&1; then
      log_success "Ruby installation test passed"
    else
      log_warning "Ruby installation test failed"
    fi
  else
    log_error "Ruby installation verification failed"
    log_info "Please restart your shell and try again"
    exit 1
  fi
}

# Setup Ruby development environment
setup_ruby_development() {
  log_info "Setting up Ruby development environment..."
  
  # Create a sample Gemfile for testing
  local test_dir="$HOME/tmp/ruby-test"
  if [[ ! -d "$test_dir" ]]; then
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    cat > Gemfile << 'EOF'
source 'https://rubygems.org'

gem 'rake'
gem 'rspec'
EOF
    
    if command -v bundle >/dev/null 2>&1; then
      bundle install --quiet >/dev/null 2>&1
      if [[ -f "Gemfile.lock" ]]; then
        log_success "Bundler working correctly"
        rm -rf "$test_dir"
      fi
    fi
  fi
}

# Add Ruby project management optimization
optimize_ruby_project_management() {
  log_info "Optimizing Ruby project management..."
  
  # Parse command line options
  parse_install_options "$@"
  
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would optimize Ruby project management"
    return 0
  fi
  
  if ! command -v rbenv >/dev/null 2>&1; then
    log_info "rbenv not available, skipping Ruby optimization"
    return 0
  fi
  
  # Update gem sources and optimize gem installation
  if command -v gem >/dev/null 2>&1 && [[ "$DRY_RUN" != "true" ]]; then
    log_info "Updating RubyGems system..."
    gem update --system --no-document >/dev/null 2>&1 || log_warning "Failed to update RubyGems"
    
    # Set gem defaults for faster installation
    local gem_config_dir="$HOME/.gem"
    mkdir -p "$gem_config_dir"
    
    if [[ ! -f "$gem_config_dir/gemrc" ]]; then
      cat > "$gem_config_dir/gemrc" << 'EOF'
install: --no-document
update: --no-document
gem: --no-document
EOF
      log_info "Created gem configuration for faster installations"
    fi
  fi
  
  # Check for outdated gems and suggest updates
  if command -v bundle >/dev/null 2>&1 && [[ "$DRY_RUN" != "true" ]]; then
    log_info "Checking for outdated gems..."
    local outdated_gems
    outdated_gems=$(gem outdated 2>/dev/null | wc -l || echo 0)
    
    if (( outdated_gems > 0 )); then
      log_info "Found $outdated_gems outdated gems. Consider running 'gem update' to update them."
    else
      log_success "All gems are up to date"
    fi
  fi
  
  log_success "Ruby project management optimization completed"
}

# Main installation function
main() {
  log_info "Ruby SDK Setup via rbenv"
  log_info "========================="
  
  # Setup cleanup trap
  trap cleanup_sudo_keeper EXIT
  
  # Parse command line options
  parse_install_options "$@"
  
  # Get target Ruby version
  local ruby_version
  ruby_version=$(get_ruby_lts_version)
  
  # Check if Ruby installation should be skipped
  if should_skip_installation_advanced "Ruby" "ruby" "$ruby_version" "--version"; then
    # Even if Ruby is installed, check and update environment
    log_info "Ruby is installed, checking environment and gems..."
    
    # Perform comprehensive environment check
    check_ruby_environment
    
    # Setup/verify environment
    setup_ruby_environment
    
    # Install/update essential gems
    install_ruby_tools "$@"
    
    # Ruby project management optimization
    if [[ "$QUICK_CHECK" != "true" ]]; then
      optimize_ruby_project_management "$@"
    fi
    
    verify_ruby_installation
    cleanup_sudo_keeper
    return 0
  fi
  
  log_info "Determining Ruby version..."
  if [[ "${RUBY_VERSION:-}" == "lts" ]]; then
    log_info "LTS version requested, resolved to: $ruby_version"
  else
    log_info "Using specified Ruby version: $ruby_version"
  fi
  
  # Check sudo access for dependency installation
  if [[ "$SKIP_DEPS" != "true" ]]; then
    check_sudo_access
    # Install platform dependencies
    execute_if_not_dry_run "Install Ruby build dependencies" install_ruby_dependencies
  fi
  
  # Install rbenv
  execute_if_not_dry_run "Install rbenv" install_rbenv
  
  # Install ruby-build plugin
  execute_if_not_dry_run "Install ruby-build plugin" install_ruby_build
  
  # Install Ruby version
  execute_if_not_dry_run "Install Ruby $ruby_version" install_ruby_version "$ruby_version"
  
  # Setup environment after Ruby installation
  setup_ruby_environment
  
  # Install essential gems
  install_ruby_tools "$@"
  
  # Ruby project management optimization (skip in quick mode)
  if [[ "$QUICK_CHECK" != "true" ]]; then
    optimize_ruby_project_management "$@"
  fi
  
  # Setup development environment
  if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
    setup_ruby_development
  fi
  
  # Verify installation
  if [[ "$DRY_RUN" != "true" ]]; then
    verify_ruby_installation
  fi
  
  # Cleanup sudo keeper
  cleanup_sudo_keeper
  
  log_success "Ruby SDK setup completed!"
  log_info ""
  log_info "Available rbenv commands:"
  log_info "  rbenv versions          # List installed Ruby versions"
  log_info "  rbenv install <version> # Install specific Ruby version"
  log_info "  rbenv global <version>  # Set global Ruby version"
  log_info "  rbenv local <version>   # Set local Ruby version for project"
  log_info "  rbenv which <command>   # Show path to command"
  log_info ""
  log_info "Ruby development tools:"
  log_info "  ruby --version          # Show Ruby version"
  log_info "  gem list                # List installed gems"
  log_info "  bundle install          # Install project dependencies"
  log_info "  rubocop                 # Code linter and formatter"
  log_info "  pry                     # Interactive debugging console"
  log_info ""
  log_info "Gem management:"
  log_info "  gem update              # Update all gems"
  log_info "  gem outdated            # Show outdated gems"
  log_info "  gem cleanup             # Remove old gem versions"
  log_info ""
  log_info "Project management:"
  log_info "  bundle init             # Create new Gemfile"
  log_info "  bundle exec <command>   # Run command with bundler"
  log_info "  bundle config --list    # Show bundler configuration"
  log_info ""
  if [[ "$DRY_RUN" != "true" ]]; then
    log_info "Current configuration:"
    log_info "  Ruby version: $(ruby --version 2>/dev/null || echo 'not available')"
    log_info "  rbenv root: $(rbenv root 2>/dev/null || echo 'not available')"
    log_info "  Global Ruby: $(rbenv global 2>/dev/null || echo 'not set')"
    log_info "  Gem directory: $(gem env gemdir 2>/dev/null || echo 'not available')"
  fi
  log_info ""
  log_info "Environment setup:"
  log_info "  Add to your shell profile (~/.zshrc or ~/.bashrc):"
  log_info "    export PATH=\"\$HOME/.rbenv/bin:\$PATH\""
  log_info "    eval \"\$(rbenv init -)\""
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"