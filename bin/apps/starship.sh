#!/usr/bin/env bash

# Starship (cross-shell prompt) installation and configuration management script
# This script installs Starship and manages configuration with diff detection

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

log_info "Starting Starship (cross-shell prompt) setup..."

# =============================================================================
# Enhanced Starship Configuration Diff Detection Functions
# =============================================================================

# Check Starship installation and configuration
check_starship_environment() {
    log_info "Checking Starship environment..."
    
    local all_checks_passed=true
    
    # Check Starship command availability
    if ! is_command_available "starship" "--version"; then
        log_info "Starship not available"
        all_checks_passed=false
    else
        # Check Starship configuration file
        local starship_config="$HOME/.config/starship.toml"
        if [[ ! -f "$starship_config" ]]; then
            log_warning "Starship configuration not found: $starship_config"
        else
            log_info "Starship configuration found: $starship_config"
        fi
        
        # Check shell integration
        check_shell_integration
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "Starship environment checks passed"
        return 0
    else
        log_info "Starship environment checks failed"
        return 1
    fi
}

# Check shell integration for Starship
check_shell_integration() {
    log_info "Checking Starship shell integration..."
    
    # Check common shell configurations
    local shell_configs=(
        "$HOME/.zshrc:zsh"
        "$HOME/.bashrc:bash"
        "$HOME/.config/fish/config.fish:fish"
    )
    
    local integration_found=false
    
    for config_info in "${shell_configs[@]}"; do
        local config_file=$(echo "$config_info" | cut -d: -f1)
        local shell_name=$(echo "$config_info" | cut -d: -f2)
        
        if [[ -f "$config_file" ]]; then
            if grep -q "starship init" "$config_file" 2>/dev/null; then
                log_info "Starship integration found in $shell_name: $config_file"
                integration_found=true
            fi
        fi
    done
    
    if [[ "$integration_found" == "true" ]]; then
        log_success "Starship shell integration configured"
    else
        log_warning "No Starship shell integration found"
        log_info "Add 'eval \"\$(starship init zsh)\"' to your shell configuration"
    fi
}

# Check Starship version requirements
check_starship_version_requirements() {
    local required_version="${STARSHIP_VERSION:-1.0.0}"
    
    log_info "Checking Starship version requirements (>= $required_version)..."
    
    if ! command -v starship >/dev/null 2>&1; then
        log_info "Starship command not available"
        return 1
    fi
    
    # Starship version output format: "starship 1.16.0"
    local current_version
    current_version=$(starship --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine Starship version"
        return 1
    fi
    
    compare_versions "$current_version" "$required_version"
    local result=$?
    
    case $result in
        0|2)  # current >= required
            log_success "Starship version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "Starship version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for Starship"
            return 1
            ;;
    esac
}

# Enhanced configuration diff detection
check_starship_configuration_diff() {
    log_info "Checking Starship configuration differences..."
    
    local source_config="$DOTFILES_DIR/.config/starship.toml"
    local target_config="$HOME/.config/starship.toml"
    
    if [[ ! -f "$source_config" ]]; then
        log_warning "Source Starship configuration not found: $source_config"
        return 1
    fi
    
    if [[ ! -f "$target_config" ]]; then
        log_info "Target Starship configuration not found: $target_config"
        return 1
    fi
    
    # Check if configurations are identical using hash comparison
    if is_config_hash_unchanged "$source_config" "$target_config"; then
        return 0
    fi
    
    # Show detailed differences if configurations differ
    log_info "Configuration differences detected:"
    if command -v diff >/dev/null 2>&1; then
        local diff_output
        diff_output=$(diff -u "$target_config" "$source_config" 2>/dev/null | head -20)
        if [[ -n "$diff_output" ]]; then
            log_info "Configuration diff (first 20 lines):"
            echo "$diff_output"
        fi
    fi
    
    return 1
}

# Analyze Starship configuration features
analyze_starship_configuration() {
    log_info "Analyzing Starship configuration features..."
    
    local config_file="$HOME/.config/starship.toml"
    
    if [[ ! -f "$config_file" ]]; then
        log_info "No Starship configuration to analyze"
        return 0
    fi
    
    # Count enabled modules
    local module_count
    module_count=$(grep -c "^\[.*\]" "$config_file" 2>/dev/null || echo 0)
    log_info "Configuration modules: $module_count"
    
    # Check for common modules
    local common_modules=(
        "git_branch"
        "git_status"
        "directory"
        "nodejs"
        "python"
        "rust"
        "docker_context"
    )
    
    local enabled_modules=0
    for module in "${common_modules[@]}"; do
        if grep -q "^\[$module\]" "$config_file" 2>/dev/null; then
            enabled_modules=$((enabled_modules + 1))
        fi
    done
    
    log_info "Common modules enabled: $enabled_modules/${#common_modules[@]}"
    
    # Check for custom styling
    if grep -q "format\|symbol\|style" "$config_file" 2>/dev/null; then
        log_info "Custom styling detected in configuration"
    fi
    
    log_success "Starship configuration analysis completed"
}

# Comprehensive Starship environment check
check_starship_comprehensive_environment() {
    log_info "Performing comprehensive Starship environment check..."
    
    local all_checks_passed=true
    
    # Check Starship installation
    if ! check_starship_environment; then
        all_checks_passed=false
    fi
    
    # Check version requirements
    if ! check_starship_version_requirements; then
        all_checks_passed=false
    fi
    
    # Check configuration differences
    if ! check_starship_configuration_diff; then
        log_info "Starship configuration needs update"
        all_checks_passed=false
    fi
    
    # Analyze configuration
    analyze_starship_configuration
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All Starship environment checks passed"
        return 0
    else
        log_info "Some Starship environment checks failed"
        return 1
    fi
}

# Install Starship with enhanced options
install_starship() {
    log_info "Installing Starship..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Starship"
        return 0
    fi
    
    # Create local bin directory
    local install_dir="$HOME/.local/bin"
    execute_if_not_dry_run "Create local bin directory" mkdir -p "$install_dir"
    
    # Download and install Starship
    log_info "Downloading Starship installer..."
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Use official installer with appropriate flags
        if curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$install_dir" --yes; then
            log_success "Starship installed successfully"
            
            # Add to PATH for current session
            export PATH="$install_dir:$PATH"
            
            # Verify installation
            if command -v starship >/dev/null 2>&1; then
                log_info "Starship version: $(starship --version)"
            fi
        else
            log_error "Failed to install Starship"
            return 1
        fi
    else
        log_info "[DRY RUN] Would download and install Starship to $install_dir"
    fi
}

# Setup Starship configuration with diff detection
setup_starship_configuration() {
    log_info "Setting up Starship configuration..."
    
    # Parse command line options
    parse_install_options "$@"
    
    local source_config="$DOTFILES_DIR/.config/starship.toml"
    local target_config="$HOME/.config/starship.toml"
    local config_dir="$HOME/.config"
    
    # Create config directory
    execute_if_not_dry_run "Create config directory" mkdir -p "$config_dir"
    
    # Check if configuration needs update
    if [[ "$FORCE_INSTALL" != "true" ]] && is_config_up_to_date "$source_config" "$target_config" 24; then
        log_skip_reason "Starship configuration" "Already up to date"
        return 0
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would setup Starship configuration"
        return 0
    fi
    
    if [[ -f "$source_config" ]]; then
        if [[ "$DRY_RUN" != "true" ]]; then
            # Backup existing configuration
            if [[ -f "$target_config" ]]; then
                local backup_file="${target_config}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$target_config" "$backup_file"
                log_info "Backed up existing configuration to: $backup_file"
            fi
            
            # Copy new configuration
            cp "$source_config" "$target_config"
            log_success "Starship configuration updated"
            
            # Verify configuration
            if command -v starship >/dev/null 2>&1; then
                if starship config >/dev/null 2>&1; then
                    log_success "Starship configuration is valid"
                else
                    log_warning "Starship configuration may have issues"
                fi
            fi
        else
            log_info "[DRY RUN] Would copy configuration from $source_config to $target_config"
        fi
    else
        log_warning "Source Starship configuration not found: $source_config"
        log_info "Configuration will be managed manually"
    fi
}

# Optimize Starship configuration and performance
optimize_starship_configuration() {
    log_info "Optimizing Starship configuration and performance..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would optimize Starship configuration"
        return 0
    fi
    
    if ! command -v starship >/dev/null 2>&1; then
        log_info "Starship not available, skipping optimization"
        return 0
    fi
    
    # Check shell integration and suggest improvements
    local shell_name
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        shell_name="zsh"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        shell_name="bash"
    else
        shell_name="unknown"
    fi
    
    log_info "Current shell: $shell_name"
    
    # Analyze performance
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Testing Starship performance..."
        local start_time=$(date +%s%N)
        starship prompt >/dev/null 2>&1
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        log_info "Starship prompt generation time: ${duration}ms"
        
        if (( duration > 100 )); then
            log_warning "Starship prompt is slow (>${duration}ms). Consider optimizing configuration."
        else
            log_success "Starship prompt performance is good (${duration}ms)"
        fi
    fi
    
    log_success "Starship optimization completed"
}

# Main installation function
main() {
    log_info "Starship (Cross-Shell Prompt) Setup"
    log_info "==================================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Get target Starship version
    local starship_version="${STARSHIP_VERSION:-1.0.0}"
    
    # Check if Starship installation should be skipped
    if should_skip_installation_advanced "Starship" "starship" "$starship_version" "--version"; then
        # Even if Starship is installed, check and update configuration
        log_info "Starship is installed, checking configuration and environment..."
        
        # Perform comprehensive environment check
        check_starship_comprehensive_environment
        
        # Setup/verify configuration
        setup_starship_configuration "$@"
        
        # Optimize configuration and performance
        if [[ "$QUICK_CHECK" != "true" ]]; then
            optimize_starship_configuration "$@"
        fi
        
        return 0
    fi
    
    # Install Starship
    install_starship "$@"
    
    # Setup configuration
    setup_starship_configuration "$@"
    
    # Optimize configuration and performance (skip in quick mode)
    if [[ "$QUICK_CHECK" != "true" ]]; then
        optimize_starship_configuration "$@"
    fi
    
    log_success "Starship setup completed!"
    log_info ""
    log_info "Available Starship commands:"
    log_info "  starship --version          # Show Starship version"
    log_info "  starship config             # Validate configuration"
    log_info "  starship prompt             # Generate prompt"
    log_info "  starship explain            # Show config explanation"
    log_info "  starship timings            # Show module timings"
    log_info ""
    log_info "Shell integration:"
    log_info "  Add to ~/.zshrc:   eval \"\$(starship init zsh)\""
    log_info "  Add to ~/.bashrc:  eval \"\$(starship init bash)\""
    log_info "  Add to fish:       starship init fish | source"
    log_info ""
    log_info "Configuration:"
    log_info "  Config file: ~/.config/starship.toml"
    log_info "  Documentation: https://starship.rs/config/"
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current status:"
        log_info "  Starship version: $(starship --version 2>/dev/null || echo 'not available')"
        log_info "  Configuration: $(ls -la ~/.config/starship.toml 2>/dev/null | awk '{print $5" bytes"}' || echo 'not found')"
        log_info "  Install location: $(which starship 2>/dev/null || echo 'not in PATH')"
    fi
    log_info ""
    log_info "Getting started:"
    log_info "  1. Add shell integration to your shell profile"
    log_info "  2. Restart your shell or source the profile"
    log_info "  3. Customize ~/.config/starship.toml as needed"
    log_info ""
    log_info "Note: Configuration is managed via dotfiles symlinks"
}

# Run main function
main "$@"