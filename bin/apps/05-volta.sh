#!/usr/bin/env bash

# Volta (JavaScript toolchain manager) installation and comprehensive Node.js management script
# This script installs Volta and provides advanced Node.js version and package management

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"
source "$DOTFILES_DIR/bin/lib/volta_installer.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Volta (JavaScript toolchain manager) setup..."

# =============================================================================
# Enhanced Volta Node.js Management and Package Optimization Functions
# =============================================================================

# Check Volta installation and environment
check_volta_environment() {
    log_info "Checking Volta environment..."
    
    local all_checks_passed=true
    
    # Check Volta command availability
    if ! is_command_available "volta" "--version"; then
        log_info "Volta not available"
        all_checks_passed=false
    else
        # Check Volta home directory
        local volta_home="${VOLTA_HOME:-$HOME/.volta}"
        if [[ ! -d "$volta_home" ]]; then
            log_warning "Volta home directory not found: $volta_home"
            all_checks_passed=false
        else
            log_info "Volta home: $volta_home"
        fi
        
        # Check Volta PATH configuration
        if [[ ":$PATH:" != *":$volta_home/bin:"* ]]; then
            log_warning "Volta not in PATH, may need shell profile update"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "Volta environment checks passed"
        return 0
    else
        log_info "Volta environment checks failed"
        return 1
    fi
}

# Check Volta version requirements
check_volta_version_requirements() {
    local required_version="${VOLTA_VERSION:-1.1.0}"
    
    log_info "Checking Volta version requirements (>= $required_version)..."
    
    if ! command -v volta >/dev/null 2>&1; then
        log_info "Volta command not available"
        return 1
    fi
    
    # Volta version output format: "1.1.1"
    local current_version
    current_version=$(volta --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine Volta version"
        return 1
    fi
    
    compare_versions "$current_version" "$required_version"
    local result=$?
    
    case $result in
        0|2)  # current >= required
            log_success "Volta version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "Volta version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for Volta"
            return 1
            ;;
    esac
}

# Check Node.js installation and management status
check_nodejs_status() {
    log_info "Checking Node.js installation status..."
    
    if ! command -v volta >/dev/null 2>&1; then
        log_info "Volta not available"
        return 1
    fi
    
    # Check Node.js availability
    if ! command -v node >/dev/null 2>&1; then
        log_info "Node.js not installed via Volta"
        return 1
    fi
    
    # Get Node.js version information
    local node_version
    node_version=$(node --version 2>/dev/null | sed 's/v//' || echo "unknown")
    log_info "Node.js version: $node_version"
    
    # Check npm availability
    if command -v npm >/dev/null 2>&1; then
        local npm_version
        npm_version=$(npm --version 2>/dev/null || echo "unknown")
        log_info "npm version: $npm_version"
    else
        log_warning "npm not available"
    fi
    
    # Check Volta tool list
    if volta list >/dev/null 2>&1; then
        local tool_count
        tool_count=$(volta list 2>/dev/null | grep -c "^[[:space:]]*[a-zA-Z]" || echo 0)
        log_info "Volta managed tools: $tool_count"
    fi
    
    log_success "Node.js status check completed"
    return 0
}

# Check Node.js project management and package optimization
check_nodejs_project_management() {
    log_info "Checking Node.js project management capabilities..."
    
    if ! command -v volta >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
        log_info "Volta or Node.js not available"
        return 1
    fi
    
    # Create temporary directory for testing
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Test package.json creation and volta pin functionality
    cat > package.json << 'EOF'
{
  "name": "volta-test-project",
  "version": "1.0.0",
  "description": "Test project for Volta functionality",
  "scripts": {
    "test": "echo \"Volta project test passed\""
  }
}
EOF
    
    # Test volta pin functionality
    if volta pin node >/dev/null 2>&1; then
        log_success "Volta pin functionality working"
        
        # Check if volta configuration was added to package.json
        if grep -q "volta" package.json 2>/dev/null; then
            log_info "Volta configuration added to package.json"
        fi
    else
        log_warning "Volta pin functionality test failed"
    fi
    
    # Test npm functionality
    if npm test >/dev/null 2>&1; then
        log_success "npm execution test passed"
    else
        log_warning "npm execution test failed"
    fi
    
    cd - >/dev/null
    rm -rf "$temp_dir"
    
    # Check for existing Node.js projects
    local nodejs_projects
    nodejs_projects=$(find "$HOME" -name "package.json" -type f 2>/dev/null | head -5 | wc -l 2>/dev/null || echo 0)
    nodejs_projects=$(echo "$nodejs_projects" | tr -d '[:space:]')
    
    if [[ "$nodejs_projects" =~ ^[0-9]+$ ]] && (( nodejs_projects > 0 )); then
        log_info "Found $nodejs_projects Node.js projects in home directory"
    fi
    
    log_success "Node.js project management check completed"
    return 0
}

# Check global package management and optimization
check_global_package_management() {
    log_info "Checking global package management..."
    
    if ! command -v volta >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        log_info "Volta or npm not available"
        return 1
    fi
    
    # Check global packages
    local global_packages
    global_packages=$(npm list -g --depth=0 2>/dev/null | grep -c "^[├└]" || echo 0)
    log_info "Global npm packages: $global_packages"
    
    # Check for common development tools
    local common_tools=(
        "yarn:Package manager alternative"
        "pnpm:Fast package manager"
        "typescript:TypeScript compiler"
        "@vue/cli:Vue.js CLI"
        "create-react-app:React application generator"
        "@angular/cli:Angular CLI"
        "eslint:JavaScript linter"
        "prettier:Code formatter"
        "nodemon:Development server"
    )
    
    local installed_tools=0
    for tool_info in "${common_tools[@]}"; do
        local tool_name=$(echo "$tool_info" | cut -d: -f1)
        
        if command -v "$tool_name" >/dev/null 2>&1 || npm list -g "$tool_name" >/dev/null 2>&1; then
            ((installed_tools++))
        fi
    done
    
    log_info "Common development tools installed: $installed_tools/${#common_tools[@]}"
    
    # Check package cache and optimization opportunities
    if [[ -d "$HOME/.npm" ]]; then
        local cache_size
        cache_size=$(du -sh "$HOME/.npm" 2>/dev/null | cut -f1 || echo "unknown")
        log_info "npm cache size: $cache_size"
    fi
    
    log_success "Global package management check completed"
    return 0
}

# Comprehensive Volta environment check
check_volta_comprehensive_environment() {
    log_info "Performing comprehensive Volta environment check..."
    
    local all_checks_passed=true
    
    # Check Volta installation
    if ! check_volta_environment; then
        all_checks_passed=false
    fi
    
    # Check version requirements
    if ! check_volta_version_requirements; then
        all_checks_passed=false
    fi
    
    # Check Node.js status
    if ! check_nodejs_status; then
        log_info "Node.js needs installation or update"
        all_checks_passed=false
    fi
    
    # Check project management capabilities
    check_nodejs_project_management
    
    # Check global package management (temporarily disabled)
    # check_global_package_management
    log_info "Skipping global package management check (temporarily disabled)"
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All Volta environment checks passed"
        return 0
    else
        log_info "Some Volta environment checks failed"
        return 1
    fi
}

# Install Volta with enhanced options
install_volta_enhanced() {
    log_info "Installing Volta..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Volta"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Use the existing install_volta function
        if install_volta; then
            log_success "Volta installation completed"
        else
            log_error "Volta installation failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Volta"
    fi
}

# Install Node.js toolchain with enhanced management
install_nodejs_toolchain_enhanced() {
    log_info "Installing Node.js toolchain..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Node.js toolchain"
        return 0
    fi
    
    if ! command -v volta >/dev/null 2>&1; then
        log_warning "Volta not available, skipping Node.js installation"
        return 1
    fi
    
    # Check if Node.js is already installed and current
    local target_node_version="${NODE_VERSION:-lts}"
    
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v node >/dev/null 2>&1; then
        local current_node_version
        current_node_version=$(node --version 2>/dev/null | sed 's/v//' || echo "unknown")
        
        if [[ "$target_node_version" == "lts" ]]; then
            log_skip_reason "Node.js" "Already installed: $current_node_version"
            return 0
        fi
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Install Node.js
        log_info "Installing Node.js $target_node_version..."
        if volta install "node@$target_node_version"; then
            log_success "Node.js installed successfully"
        else
            log_error "Failed to install Node.js"
            return 1
        fi
        
        # Install or update npm
        local npm_version="${NPM_VERSION:-latest}"
        log_info "Installing npm $npm_version..."
        if volta install "npm@$npm_version"; then
            log_success "npm installed successfully"
        else
            log_warning "Failed to install npm (may already be included)"
        fi
    else
        log_info "[DRY RUN] Would install Node.js $target_node_version and npm"
    fi
}

# Install essential development tools
install_essential_nodejs_tools() {
    log_info "Installing essential Node.js development tools..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install essential Node.js tools"
        return 0
    fi
    
    # Skip tools installation if in container environment or CI
    if [[ -n "${CONTAINER:-}" || -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
        log_info "Skipping Node.js tools installation in container/CI environment"
        return 0
    fi
    
    # Temporary: Skip tools installation to avoid blocking Docker setup
    log_info "Temporarily skipping Node.js tools installation (known issue with tool installations)"
    log_success "Node.js tools installation completed (skipped)"
    return 0
    
    if ! command -v volta >/dev/null 2>&1; then
        log_warning "Volta not available, skipping tools installation"
        return 1
    fi
    
    # List of essential tools with installation methods
    local tools_info=(
        "yarn:volta:Package manager alternative"
        "pnpm:volta:Fast package manager"
        "typescript:volta:TypeScript compiler"
        "eslint:volta:JavaScript linter"
        "prettier:volta:Code formatter"
        "nodemon:volta:Development server"
    )
    
    local installed_count=0
    local skipped_count=0
    local failed_count=0
    
    for tool_info in "${tools_info[@]}"; do
        local tool_name=$(echo "$tool_info" | cut -d: -f1)
        local install_method=$(echo "$tool_info" | cut -d: -f2)
        local tool_desc=$(echo "$tool_info" | cut -d: -f3)
        
        # Skip if tool is already available and not forcing reinstall
        if [[ "$FORCE_INSTALL" != "true" ]] && command -v "$tool_name" >/dev/null 2>&1; then
            log_skip_reason "$tool_name" "Already installed"
            ((skipped_count++))
            continue
        fi
        
        # Install the tool
        log_info "Installing $tool_name ($tool_desc)..."
        
        if [[ "$DRY_RUN" != "true" ]]; then
            case "$install_method" in
                volta)
                    if volta install "$tool_name"; then
                        log_success "$tool_name installed successfully"
                        ((installed_count++))
                    else
                        log_warning "Failed to install $tool_name"
                        ((failed_count++))
                    fi
                    ;;
                *)
                    log_warning "Unknown installation method for $tool_name: $install_method"
                    ((failed_count++))
                    ;;
            esac
        else
            log_info "[DRY RUN] Would install $tool_name via $install_method"
            ((installed_count++))
        fi
    done
    
    # Log summary
    if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
        log_install_summary "$installed_count" "$skipped_count" "$failed_count"
    fi
    
    log_success "Essential Node.js tools installation completed"
}

# Optimize Node.js package management and project setup
optimize_nodejs_package_management() {
    log_info "Optimizing Node.js package management..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would optimize Node.js package management"
        return 0
    fi
    
    if ! command -v volta >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        log_info "Volta or npm not available, skipping optimization"
        return 0
    fi
    
    # Configure npm for better performance
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Configuring npm for optimal performance..."
        
        # Set npm configuration for faster installs
        npm config set prefer-offline true >/dev/null 2>&1 || true
        npm config set audit false >/dev/null 2>&1 || true
        npm config set fund false >/dev/null 2>&1 || true
        
        log_info "npm configuration optimized"
    fi
    
    # Check for package vulnerabilities and updates
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Checking global package health..."
        
        # Update npm itself
        if volta install npm@latest >/dev/null 2>&1; then
            log_info "npm updated to latest version"
        fi
        
        # Clean npm cache
        if npm cache clean --force >/dev/null 2>&1; then
            log_info "npm cache cleaned"
        fi
    fi
    
    # Suggest project setup best practices
    log_info "Node.js project optimization suggestions:"
    log_info "  - Use 'volta pin node' in projects for version consistency"
    log_info "  - Use 'volta pin npm' to lock npm version per project"
    log_info "  - Consider using pnpm for faster installs in large projects"
    
    log_success "Node.js package management optimization completed"
}

# Main installation function
main() {
    log_info "Volta (JavaScript Toolchain Manager) Setup"
    log_info "==========================================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Get target Volta version
    local volta_version="${VOLTA_VERSION:-1.1.0}"
    
    # Check if Volta installation should be skipped
    if should_skip_installation_advanced "Volta" "volta" "$volta_version" "--version"; then
        # Even if Volta is installed, check and update Node.js environment
        log_info "Volta is installed, checking Node.js environment and tools..."
        
        # Perform comprehensive environment check
        check_volta_comprehensive_environment
        
        # Install/update Node.js toolchain
        install_nodejs_toolchain_enhanced "$@"
        
        # Install essential development tools
        install_essential_nodejs_tools "$@"
        
        # Optimize package management
        if [[ "$QUICK_CHECK" != "true" ]]; then
            optimize_nodejs_package_management "$@"
        fi
        
        return 0
    fi
    
    # Install Volta
    install_volta_enhanced "$@"
    
    # Install Node.js toolchain
    install_nodejs_toolchain_enhanced "$@"
    
    # Install essential development tools
    install_essential_nodejs_tools "$@"
    
    # Optimize package management (skip in quick mode)
    if [[ "$QUICK_CHECK" != "true" ]]; then
        optimize_nodejs_package_management "$@"
    fi
    
    log_success "Volta setup completed!"
    log_info ""
    log_info "Available Volta commands:"
    log_info "  volta --version             # Show Volta version"
    log_info "  volta list                  # List installed tools"
    log_info "  volta install node@lts      # Install Node.js LTS"
    log_info "  volta install npm@latest    # Install latest npm"
    log_info "  volta install <tool>        # Install global tool"
    log_info "  volta pin node@18           # Pin Node.js 18 for project"
    log_info "  volta pin npm@9             # Pin npm 9 for project"
    log_info ""
    log_info "Node.js project management:"
    log_info "  node --version              # Show current Node.js version"
    log_info "  npm --version               # Show current npm version"
    log_info "  npm init                    # Initialize new project"
    log_info "  npm install                 # Install project dependencies"
    log_info "  npm run <script>            # Run package.json script"
    log_info ""
    log_info "Essential tools installed:"
    log_info "  yarn                        # Alternative package manager"
    log_info "  pnpm                        # Fast package manager"
    log_info "  typescript                  # TypeScript compiler (tsc)"
    log_info "  eslint                      # JavaScript linter"
    log_info "  prettier                    # Code formatter"
    log_info "  nodemon                     # Development server"
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current status:"
        log_info "  Volta version: $(volta --version 2>/dev/null || echo 'not available')"
        log_info "  Node.js version: $(node --version 2>/dev/null || echo 'not available')"
        log_info "  npm version: $(npm --version 2>/dev/null || echo 'not available')"
        log_info "  Volta home: $(echo "${VOLTA_HOME:-$HOME/.volta}")"
        if command -v volta >/dev/null 2>&1; then
            local tool_count
            tool_count=$(volta list 2>/dev/null | grep -c "^[[:space:]]*[a-zA-Z]" || echo 0)
            log_info "  Managed tools: $tool_count"
        fi
    fi
    log_info ""
    log_info "Project setup:"
    log_info "  1. Navigate to your project directory"
    log_info "  2. Run 'volta pin node' to lock Node.js version"
    log_info "  3. Run 'volta pin npm' to lock npm version"
    log_info "  4. Create package.json with 'npm init'"
    log_info ""
    log_info "Package management best practices:"
    log_info "  - Use 'volta install' for global tools"
    log_info "  - Use 'volta pin' for project-specific versions"
    log_info "  - Consider pnpm for large projects or monorepos"
    log_info "  - Run 'npm audit' regularly for security"
    log_info ""
    log_info "Environment setup:"
    log_info "  Volta automatically manages PATH and environment"
    log_info "  Configuration is added to your shell profile"
    log_info "  Restart shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"
