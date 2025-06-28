#!/usr/bin/env bash

# Sheldon (zsh plugin manager) installation and incremental update system
# This script installs Sheldon and manages plugins with incremental updates

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

log_info "Starting Sheldon (zsh plugin manager) setup..."

# =============================================================================
# Enhanced Sheldon Incremental Update System Functions
# =============================================================================

# Check Sheldon installation and configuration
check_sheldon_environment() {
    log_info "Checking Sheldon environment..."
    
    local all_checks_passed=true
    
    # Check Sheldon command availability
    if ! is_command_available "sheldon" "--version"; then
        log_info "Sheldon not available"
        all_checks_passed=false
    else
        # Check Sheldon configuration
        local sheldon_config="$HOME/.config/sheldon/plugins.toml"
        if [[ ! -f "$sheldon_config" ]]; then
            log_warning "Sheldon configuration not found: $sheldon_config"
        else
            log_info "Sheldon configuration found: $sheldon_config"
        fi
        
        # Check Sheldon data directory
        local sheldon_data="$HOME/.local/share/sheldon"
        if [[ -d "$sheldon_data" ]]; then
            local plugin_count
            plugin_count=$(find "$sheldon_data" -maxdepth 1 -type d ! -path "$sheldon_data" 2>/dev/null | wc -l || echo 0)
            log_info "Installed Sheldon plugins: $plugin_count"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "Sheldon environment checks passed"
        return 0
    else
        log_info "Sheldon environment checks failed"
        return 1
    fi
}

# Check Sheldon version requirements
check_sheldon_version_requirements() {
    local required_version="${SHELDON_VERSION:-0.7.0}"
    
    log_info "Checking Sheldon version requirements (>= $required_version)..."
    
    if ! command -v sheldon >/dev/null 2>&1; then
        log_info "Sheldon command not available"
        return 1
    fi
    
    # Sheldon version output format: "sheldon 0.7.4"
    local current_version
    current_version=$(sheldon --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine Sheldon version"
        return 1
    fi
    
    compare_versions "$current_version" "$required_version"
    local result=$?
    
    case $result in
        0|2)  # current >= required
            log_success "Sheldon version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "Sheldon version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for Sheldon"
            return 1
            ;;
    esac
}

# Check Sheldon plugin status with incremental update tracking
check_sheldon_plugin_status() {
    log_info "Checking Sheldon plugin status and update tracking..."
    
    if ! command -v sheldon >/dev/null 2>&1; then
        log_info "Sheldon not available"
        return 1
    fi
    
    local sheldon_data="$HOME/.local/share/sheldon"
    local update_cache="$HOME/.cache/sheldon-updates"
    
    # Create update cache directory
    mkdir -p "$update_cache"
    
    if [[ -d "$sheldon_data" ]]; then
        # Count installed plugins
        local plugin_count
        plugin_count=$(find "$sheldon_data" -maxdepth 1 -type d ! -path "$sheldon_data" 2>/dev/null | wc -l || echo 0)
        log_info "Installed plugins: $plugin_count"
        
        # Check for plugin updates using cache
        local cache_file="$update_cache/last_check"
        local current_time=$(date +%s)
        local cache_valid=false
        
        if [[ -f "$cache_file" ]]; then
            local last_check
            last_check=$(cat "$cache_file" 2>/dev/null || echo 0)
            local time_diff=$((current_time - last_check))
            
            # Cache is valid for 6 hours (21600 seconds)
            if (( time_diff < 21600 )); then
                cache_valid=true
                log_info "Plugin update cache is valid (checked $(( time_diff / 3600 )) hours ago)"
            fi
        fi
        
        if [[ "$cache_valid" != "true" ]]; then
            log_info "Checking for plugin updates..."
            # Update timestamp
            echo "$current_time" > "$cache_file"
            
            # Sheldon doesn't have a direct update check, so we'll check git repos
            check_plugin_updates "$sheldon_data" "$update_cache"
        fi
    else
        log_info "No Sheldon plugins directory found"
        return 1
    fi
    
    log_success "Sheldon plugin status check completed"
    return 0
}

# Check individual plugin updates
check_plugin_updates() {
    local sheldon_data="$1"
    local update_cache="$2"
    
    local outdated_count=0
    
    for plugin_dir in "$sheldon_data"/*; do
        if [[ -d "$plugin_dir" && -d "$plugin_dir/.git" ]]; then
            local plugin_name=$(basename "$plugin_dir")
            
            cd "$plugin_dir"
            
            # Fetch latest info (quietly)
            git fetch --quiet origin 2>/dev/null || continue
            
            # Check if local is behind remote
            local local_commit
            local_commit=$(git rev-parse HEAD 2>/dev/null)
            local remote_commit
            remote_commit=$(git rev-parse origin/HEAD 2>/dev/null || git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
            
            if [[ -n "$local_commit" && -n "$remote_commit" && "$local_commit" != "$remote_commit" ]]; then
                log_info "Plugin update available: $plugin_name"
                echo "$plugin_name" >> "$update_cache/outdated_plugins"
                ((outdated_count++))
            fi
            
            cd - >/dev/null
        fi
    done
    
    if (( outdated_count > 0 )); then
        log_info "Found $outdated_count plugins with available updates"
        log_info "Run 'sheldon lock --update' to update plugins"
    else
        log_success "All plugins are up to date"
    fi
}

# Comprehensive Sheldon environment check
check_sheldon_comprehensive_environment() {
    log_info "Performing comprehensive Sheldon environment check..."
    
    local all_checks_passed=true
    
    # Check Sheldon installation
    if ! check_sheldon_environment; then
        all_checks_passed=false
    fi
    
    # Check version requirements
    if ! check_sheldon_version_requirements; then
        all_checks_passed=false
    fi
    
    # Check plugin status with incremental updates
    check_sheldon_plugin_status
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All Sheldon environment checks passed"
        return 0
    else
        log_info "Some Sheldon environment checks failed"
        return 1
    fi
}

# Install Sheldon with enhanced options
install_sheldon() {
    log_info "Installing Sheldon..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Sheldon"
        return 0
    fi
    
    # Create local bin directory
    local install_dir="$HOME/.local/bin"
    execute_if_not_dry_run "Create local bin directory" mkdir -p "$install_dir"
    
    # Download and install Sheldon
    log_info "Downloading Sheldon installer..."
    
    if [[ "$DRY_RUN" != "true" ]]; then
        if curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to "$install_dir"; then
            log_success "Sheldon installed successfully"
            
            # Add to PATH for current session
            export PATH="$install_dir:$PATH"
            
            # Verify installation
            if command -v sheldon >/dev/null 2>&1; then
                log_info "Sheldon version: $(sheldon --version)"
            fi
        else
            log_error "Failed to install Sheldon"
            return 1
        fi
    else
        log_info "[DRY RUN] Would download and install Sheldon to $install_dir"
    fi
}

# Install modern CLI tools with skip logic
install_modern_cli_tools() {
    log_info "Installing modern CLI tools..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # List of modern CLI tools with installation methods
    local tools_info=(
        "zoxide:script:https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh:Smart cd command"
        "eza:cargo:eza:Modern ls replacement"
        "bat:cargo:bat:Modern cat replacement with syntax highlighting"
        "fd:cargo:fd-find:Modern find replacement"
        "ripgrep:cargo:ripgrep:Modern grep replacement"
    )
    
    local installed_count=0
    local skipped_count=0
    local failed_count=0
    
    for tool_info in "${tools_info[@]}"; do
        local tool_name=$(echo "$tool_info" | cut -d: -f1)
        local install_method=$(echo "$tool_info" | cut -d: -f2)
        local install_target=$(echo "$tool_info" | cut -d: -f3)
        local tool_desc=$(echo "$tool_info" | cut -d: -f4)
        
        # Skip if tool is already available and not forcing reinstall
        if [[ "$FORCE_INSTALL" != "true" ]] && command -v "$tool_name" >/dev/null 2>&1; then
            log_skip_reason "$tool_name" "Already installed"
            ((skipped_count++))
            continue
        fi
        
        # Quick check mode
        if [[ "$QUICK_CHECK" == "true" ]]; then
            log_info "QUICK: Would install $tool_name ($tool_desc)"
            continue
        fi
        
        # Install the tool
        log_info "Installing $tool_name ($tool_desc)..."
        
        case "$install_method" in
            script)
                if execute_if_not_dry_run "Install $tool_name via script" install_via_script "$install_target"; then
                    ((installed_count++))
                else
                    ((failed_count++))
                fi
                ;;
            cargo)
                if execute_if_not_dry_run "Install $tool_name via cargo" install_via_cargo "$install_target"; then
                    ((installed_count++))
                else
                    ((failed_count++))
                fi
                ;;
            *)
                log_warning "Unknown installation method for $tool_name: $install_method"
                ((failed_count++))
                ;;
        esac
    done
    
    # Log summary
    if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
        log_install_summary "$installed_count" "$skipped_count" "$failed_count"
    fi
    
    log_success "Modern CLI tools installation completed"
}

# Helper function to install via script
install_via_script() {
    local script_url="$1"
    
    if curl -sS "$script_url" | bash; then
        return 0
    else
        return 1
    fi
}

# Helper function to install via cargo
install_via_cargo() {
    local package_name="$1"
    
    if ! command -v cargo >/dev/null 2>&1; then
        log_warning "Cargo not available, skipping cargo installation"
        return 1
    fi
    
    if cargo install "$package_name"; then
        return 0
    else
        return 1
    fi
}

# Setup Sheldon configuration and incremental updates
setup_sheldon_configuration() {
    log_info "Setting up Sheldon configuration and incremental updates..."
    
    # Parse command line options
    parse_install_options "$@"
    
    local source_config="$DOTFILES_DIR/.config/sheldon/plugins.toml"
    local target_config="$HOME/.config/sheldon/plugins.toml"
    local config_dir="$HOME/.config/sheldon"
    
    # Create config directory
    execute_if_not_dry_run "Create Sheldon config directory" mkdir -p "$config_dir"
    
    # Check if configuration needs update
    if [[ "$FORCE_INSTALL" != "true" ]] && is_config_up_to_date "$source_config" "$target_config" 24; then
        log_skip_reason "Sheldon configuration" "Already up to date"
    else
        # Quick check mode
        if [[ "$QUICK_CHECK" == "true" ]]; then
            log_info "QUICK: Would setup Sheldon configuration"
        elif [[ -f "$source_config" ]]; then
            if [[ "$DRY_RUN" != "true" ]]; then
                # Backup existing configuration
                if [[ -f "$target_config" ]]; then
                    local backup_file="${target_config}.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$target_config" "$backup_file"
                    log_info "Backed up existing configuration to: $backup_file"
                fi
                
                # Copy new configuration
                cp "$source_config" "$target_config"
                log_success "Sheldon configuration updated"
            else
                log_info "[DRY RUN] Would copy configuration from $source_config to $target_config"
            fi
        else
            log_warning "Source Sheldon configuration not found: $source_config"
        fi
    fi
    
    # Initialize incremental update system
    if command -v sheldon >/dev/null 2>&1 && [[ "$DRY_RUN" != "true" ]]; then
        initialize_incremental_update_system
    fi
}

# Initialize incremental update system
initialize_incremental_update_system() {
    log_info "Initializing Sheldon incremental update system..."
    
    local update_cache="$HOME/.cache/sheldon-updates"
    execute_if_not_dry_run "Create update cache directory" mkdir -p "$update_cache"
    
    # Create update tracking files
    local update_script="$update_cache/update_plugins.sh"
    
    if [[ ! -f "$update_script" ]]; then
        cat > "$update_script" << 'EOF'
#!/usr/bin/env bash
# Sheldon incremental update script

CACHE_DIR="$HOME/.cache/sheldon-updates"
LAST_CHECK_FILE="$CACHE_DIR/last_check"
OUTDATED_FILE="$CACHE_DIR/outdated_plugins"

# Check if update is needed (once per day)
CURRENT_TIME=$(date +%s)
if [[ -f "$LAST_CHECK_FILE" ]]; then
    LAST_CHECK=$(cat "$LAST_CHECK_FILE" 2>/dev/null || echo 0)
    TIME_DIFF=$((CURRENT_TIME - LAST_CHECK))
    
    # Skip if checked less than 24 hours ago
    if (( TIME_DIFF < 86400 )); then
        echo "Plugin check performed $(( TIME_DIFF / 3600 )) hours ago, skipping"
        exit 0
    fi
fi

# Update plugins
echo "Updating Sheldon plugins..."
if command -v sheldon >/dev/null 2>&1; then
    sheldon lock --update
    echo "$CURRENT_TIME" > "$LAST_CHECK_FILE"
    rm -f "$OUTDATED_FILE"
    echo "Sheldon plugins updated successfully"
else
    echo "Sheldon not found"
    exit 1
fi
EOF
        chmod +x "$update_script"
        log_success "Created incremental update script: $update_script"
    fi
    
    # Create simple update alias/function suggestion
    log_info "Incremental update system initialized"
    log_info "You can run incremental updates with: $update_script"
}

# Main installation function
main() {
    log_info "Sheldon (Zsh Plugin Manager) Setup"
    log_info "==================================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Get target Sheldon version
    local sheldon_version="${SHELDON_VERSION:-0.7.0}"
    
    # Check if Sheldon installation should be skipped
    if should_skip_installation_advanced "Sheldon" "sheldon" "$sheldon_version" "--version"; then
        # Even if Sheldon is installed, check and update configuration/plugins
        log_info "Sheldon is installed, checking configuration and plugins..."
        
        # Perform comprehensive environment check
        check_sheldon_comprehensive_environment
        
        # Setup/verify configuration and incremental updates
        setup_sheldon_configuration "$@"
        
        # Install modern CLI tools
        install_modern_cli_tools "$@"
        
        return 0
    fi
    
    # Install Sheldon
    install_sheldon "$@"
    
    # Setup configuration and incremental updates
    setup_sheldon_configuration "$@"
    
    # Install modern CLI tools
    install_modern_cli_tools "$@"
    
    log_success "Sheldon setup completed!"
    log_info ""
    log_info "Available Sheldon commands:"
    log_info "  sheldon --version           # Show Sheldon version"
    log_info "  sheldon init --shell zsh    # Generate shell integration"
    log_info "  sheldon add <plugin>        # Add a plugin"
    log_info "  sheldon remove <plugin>     # Remove a plugin"
    log_info "  sheldon lock                # Generate plugin cache"
    log_info "  sheldon lock --update       # Update all plugins"
    log_info "  sheldon source              # Source all plugins"
    log_info ""
    log_info "Configuration:"
    log_info "  Config file: ~/.config/sheldon/plugins.toml"
    log_info "  Documentation: https://sheldon.cli.rs/"
    log_info ""
    log_info "Modern CLI tools installed:"
    log_info "  zoxide                      # Smart cd command (z <dir>)"
    log_info "  eza                         # Modern ls replacement"
    log_info "  bat                         # Modern cat with syntax highlighting"
    log_info "  fd                          # Modern find replacement"
    log_info "  ripgrep (rg)                # Modern grep replacement"
    log_info ""
    log_info "Incremental update system:"
    local update_script="$HOME/.cache/sheldon-updates/update_plugins.sh"
    if [[ -f "$update_script" ]]; then
        log_info "  Update script: $update_script"
        log_info "  Automatic checks: Daily (24 hour cache)"
    fi
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current status:"
        log_info "  Sheldon version: $(sheldon --version 2>/dev/null || echo 'not available')"
        log_info "  Configuration: $(ls -la ~/.config/sheldon/plugins.toml 2>/dev/null | awk '{print $5" bytes"}' || echo 'not found')"
        log_info "  Install location: $(which sheldon 2>/dev/null || echo 'not in PATH')"
    fi
    log_info ""
    log_info "Shell integration:"
    log_info "  Add to ~/.zshrc:"
    log_info "    eval \"\$(sheldon source)\""
    log_info ""
    log_info "Getting started:"
    log_info "  1. Add shell integration to ~/.zshrc"
    log_info "  2. Restart your shell or source ~/.zshrc"
    log_info "  3. Configure plugins in ~/.config/sheldon/plugins.toml"
    log_info ""
    log_info "Note: Configuration is managed via dotfiles symlinks"
}

# Run main function
main "$@"