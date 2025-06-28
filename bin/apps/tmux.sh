#!/usr/bin/env bash

# Tmux and TPM (Tmux Plugin Manager) installation and optimization script
# This script installs tmux and manages plugins efficiently

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

log_info "Starting tmux and TPM (Tmux Plugin Manager) setup..."

# =============================================================================
# Enhanced Tmux Plugin Management and Checking Functions
# =============================================================================

# Check tmux installation and configuration
check_tmux_environment() {
    log_info "Checking tmux environment..."
    
    local all_checks_passed=true
    
    # Check tmux command availability
    if ! is_command_available "tmux" "-V"; then
        log_info "tmux not available"
        all_checks_passed=false
    else
        # Check tmux configuration
        local tmux_config="$HOME/.tmux.conf"
        if [[ ! -f "$tmux_config" ]]; then
            log_warning "tmux configuration not found: $tmux_config"
        fi
        
        # Check tmux version
        local tmux_version
        tmux_version=$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [[ -n "$tmux_version" ]]; then
            log_info "tmux version: $tmux_version"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "tmux environment checks passed"
        return 0
    else
        log_info "tmux environment checks failed"
        return 1
    fi
}

# Check TPM (Tmux Plugin Manager) installation
check_tpm_installation() {
    log_info "Checking TPM (Tmux Plugin Manager) installation..."
    
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    if [[ -d "$tpm_dir" ]]; then
        if [[ -f "$tpm_dir/tpm" ]]; then
            log_success "TPM is installed at: $tpm_dir"
            
            # Check if TPM is up to date
            cd "$tpm_dir"
            local current_commit
            current_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
            log_info "TPM commit: ${current_commit:0:8}..."
            cd - >/dev/null
            return 0
        else
            log_warning "TPM directory exists but tpm script not found"
            return 1
        fi
    else
        log_info "TPM not installed"
        return 1
    fi
}

# Check tmux plugin status
check_tmux_plugin_status() {
    log_info "Checking tmux plugin status..."
    
    local plugins_dir="$HOME/.tmux/plugins"
    
    if [[ ! -d "$plugins_dir" ]]; then
        log_info "Tmux plugins directory does not exist"
        return 1
    fi
    
    # Count installed plugins
    local plugin_count=0
    if [[ -d "$plugins_dir" ]]; then
        plugin_count=$(find "$plugins_dir" -maxdepth 1 -type d ! -path "$plugins_dir" | wc -l || echo 0)
    fi
    
    log_info "Installed tmux plugins: $plugin_count"
    
    if (( plugin_count > 0 )); then
        log_info "Plugin directories:"
        find "$plugins_dir" -maxdepth 1 -type d ! -path "$plugins_dir" -exec basename {} \; | head -5
    fi
    
    # Check if tmux configuration has plugin declarations
    local tmux_config="$HOME/.tmux.conf"
    if [[ -f "$tmux_config" ]]; then
        local plugin_declarations
        plugin_declarations=$(grep -c "set -g @plugin" "$tmux_config" 2>/dev/null || echo 0)
        log_info "Plugin declarations in config: $plugin_declarations"
    fi
    
    log_success "Tmux plugin status check completed"
    return 0
}

# Comprehensive tmux environment check
check_tmux_comprehensive_environment() {
    log_info "Performing comprehensive tmux environment check..."
    
    local all_checks_passed=true
    
    # Check tmux installation
    if ! check_tmux_environment; then
        all_checks_passed=false
    fi
    
    # Check TPM installation
    if ! check_tpm_installation; then
        log_info "TPM needs installation or update"
        all_checks_passed=false
    fi
    
    # Check plugin status
    check_tmux_plugin_status
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All tmux environment checks passed"
        return 0
    else
        log_info "Some tmux environment checks failed"
        return 1
    fi
}

# Install tmux if not available
install_tmux() {
    log_info "Installing tmux..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install tmux"
        return 0
    fi
    
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                execute_if_not_dry_run "Install tmux via Homebrew" brew install tmux
            else
                log_error "Homebrew not available on macOS"
                return 1
            fi
            ;;
        linux)
            local distro
            distro=$(get_os_distribution)
            
            case "$distro" in
                debian|ubuntu)
                    execute_if_not_dry_run "Install tmux via apt" sudo apt update && sudo apt install -y tmux
                    ;;
                arch)
                    execute_if_not_dry_run "Install tmux via pacman" sudo pacman -Syu --needed --noconfirm tmux
                    ;;
                fedora|centos|rhel)
                    execute_if_not_dry_run "Install tmux via yum/dnf" sudo yum install -y tmux || sudo dnf install -y tmux
                    ;;
                *)
                    log_warning "Unknown Linux distribution: $distro"
                    log_info "Please install tmux manually"
                    return 1
                    ;;
            esac
            ;;
        *)
            log_warning "Unsupported platform: $platform"
            log_info "Please install tmux manually"
            return 1
            ;;
    esac
    
    log_success "tmux installation completed"
}

# Enhanced TPM installation with skip logic
install_tpm() {
    log_info "Installing TPM (Tmux Plugin Manager)..."
    
    # Parse command line options
    parse_install_options "$@"
    
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    # Check if TPM should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && [[ -d "$tpm_dir" ]] && [[ -f "$tpm_dir/tpm" ]]; then
        log_skip_reason "TPM" "Already installed at $tpm_dir"
        return 0
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install TPM"
        return 0
    fi
    
    # Create plugins directory
    local plugins_dir="$HOME/.tmux/plugins"
    execute_if_not_dry_run "Create tmux plugins directory" mkdir -p "$plugins_dir"
    
    # Remove existing TPM if forced
    if [[ "$FORCE_INSTALL" == "true" && -d "$tpm_dir" ]]; then
        execute_if_not_dry_run "Remove existing TPM" rm -rf "$tpm_dir"
    fi
    
    # Clone TPM repository
    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ ! -d "$tpm_dir" ]]; then
            log_info "Cloning TPM repository..."
            if git clone https://github.com/tmux-plugins/tpm "$tpm_dir"; then
                log_success "TPM installed successfully"
            else
                log_error "Failed to clone TPM repository"
                return 1
            fi
        else
            log_info "Updating existing TPM installation..."
            cd "$tpm_dir" && git pull origin master
            cd - >/dev/null
            log_success "TPM updated successfully"
        fi
    else
        log_info "[DRY RUN] Would clone TPM to $tpm_dir"
    fi
}

# Install and manage essential tmux plugins
install_essential_tmux_plugins() {
    log_info "Installing essential tmux plugins..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install essential tmux plugins"
        return 0
    fi
    
    if ! command -v tmux >/dev/null 2>&1; then
        log_warning "tmux not available, skipping plugin installation"
        return 1
    fi
    
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -f "$tpm_dir/tpm" ]]; then
        log_warning "TPM not available, skipping plugin installation"
        return 1
    fi
    
    # List of essential plugins with descriptions
    local essential_plugins=(
        "tmux-plugins/tmux-sensible:Sensible tmux defaults"
        "tmux-plugins/tmux-resurrect:Restore tmux sessions"
        "tmux-plugins/tmux-continuum:Continuous saving of tmux environment"
        "tmux-plugins/tmux-yank:Copy to system clipboard"
        "catppuccin/tmux:Catppuccin theme for tmux"
    )
    
    local installed_count=0
    local skipped_count=0
    
    for plugin_info in "${essential_plugins[@]}"; do
        local plugin_name=$(echo "$plugin_info" | cut -d: -f1)
        local plugin_desc=$(echo "$plugin_info" | cut -d: -f2)
        local plugin_dir="$HOME/.tmux/plugins/$(basename "$plugin_name")"
        
        # Skip if plugin is already installed and not forcing
        if [[ "$FORCE_INSTALL" != "true" ]] && [[ -d "$plugin_dir" ]]; then
            log_skip_reason "$(basename "$plugin_name")" "Already installed"
            ((skipped_count++))
            continue
        fi
        
        log_info "Installing plugin: $(basename "$plugin_name") ($plugin_desc)"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            if git clone "https://github.com/$plugin_name" "$plugin_dir" >/dev/null 2>&1; then
                log_success "Installed plugin: $(basename "$plugin_name")"
                ((installed_count++))
            else
                log_warning "Failed to install plugin: $(basename "$plugin_name")"
            fi
        else
            log_info "[DRY RUN] Would install plugin: $(basename "$plugin_name")"
            ((installed_count++))
        fi
    done
    
    # Log summary
    if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
        log_install_summary "$installed_count" "$skipped_count" "0"
    fi
    
    log_success "Essential tmux plugins installation completed"
}

# Optimize tmux plugin management
optimize_tmux_plugin_management() {
    log_info "Optimizing tmux plugin management..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would optimize tmux plugin management"
        return 0
    fi
    
    local plugins_dir="$HOME/.tmux/plugins"
    
    if [[ ! -d "$plugins_dir" ]]; then
        log_info "No plugins directory found, skipping optimization"
        return 0
    fi
    
    # Update all installed plugins
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Updating installed plugins..."
        local updated_count=0
        
        for plugin_dir in "$plugins_dir"/*; do
            if [[ -d "$plugin_dir" && -d "$plugin_dir/.git" ]]; then
                local plugin_name=$(basename "$plugin_dir")
                cd "$plugin_dir"
                
                if git pull origin master >/dev/null 2>&1 || git pull origin main >/dev/null 2>&1; then
                    log_info "Updated plugin: $plugin_name"
                    ((updated_count++))
                else
                    log_warning "Failed to update plugin: $plugin_name"
                fi
                
                cd - >/dev/null
            fi
        done
        
        if (( updated_count > 0 )); then
            log_success "Updated $updated_count plugins"
        else
            log_info "All plugins are up to date"
        fi
    fi
    
    # Clean up unused plugins (check against tmux.conf)
    local tmux_config="$HOME/.tmux.conf"
    if [[ -f "$tmux_config" && "$DRY_RUN" != "true" ]]; then
        log_info "Checking for unused plugins..."
        local unused_count=0
        
        for plugin_dir in "$plugins_dir"/*; do
            if [[ -d "$plugin_dir" ]]; then
                local plugin_name=$(basename "$plugin_dir")
                
                # Skip TPM itself
                if [[ "$plugin_name" == "tpm" ]]; then
                    continue
                fi
                
                # Check if plugin is declared in tmux.conf
                if ! grep -q "@plugin.*$plugin_name" "$tmux_config" 2>/dev/null; then
                    log_info "Found potentially unused plugin: $plugin_name"
                    ((unused_count++))
                fi
            fi
        done
        
        if (( unused_count > 0 )); then
            log_info "Found $unused_count potentially unused plugins"
            log_info "Consider running TPM's clean command: prefix + alt + u"
        fi
    fi
    
    log_success "Tmux plugin management optimization completed"
}

# Main installation function
main() {
    log_info "Tmux and TPM Setup"
    log_info "=================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if tmux installation should be skipped
    local required_version="${TMUX_VERSION:-2.0}"
    if should_skip_installation_advanced "tmux" "tmux" "$required_version" "-V"; then
        # Even if tmux is installed, check and update plugins
        log_info "tmux is installed, checking plugins and environment..."
        
        # Perform comprehensive environment check
        check_tmux_comprehensive_environment
        
        # Install/update TPM
        install_tpm "$@"
        
        # Install essential plugins
        install_essential_tmux_plugins "$@"
        
        # Optimize plugin management
        if [[ "$QUICK_CHECK" != "true" ]]; then
            optimize_tmux_plugin_management "$@"
        fi
        
        return 0
    fi
    
    # Install tmux
    install_tmux "$@"
    
    # Install TPM
    install_tpm "$@"
    
    # Install essential plugins
    install_essential_tmux_plugins "$@"
    
    # Optimize plugin management (skip in quick mode)
    if [[ "$QUICK_CHECK" != "true" ]]; then
        optimize_tmux_plugin_management "$@"
    fi
    
    log_success "Tmux and TPM setup completed!"
    log_info ""
    log_info "Available tmux commands:"
    log_info "  tmux new-session -s <name>  # Create new session"
    log_info "  tmux list-sessions           # List sessions"
    log_info "  tmux attach -t <name>        # Attach to session"
    log_info "  tmux kill-session -t <name>  # Kill session"
    log_info ""
    log_info "TPM (Tmux Plugin Manager) commands:"
    log_info "  prefix + I                   # Install plugins"
    log_info "  prefix + U                   # Update plugins"
    log_info "  prefix + alt + u             # Uninstall unused plugins"
    log_info ""
    log_info "Essential plugins installed:"
    log_info "  tmux-sensible               # Sensible defaults"
    log_info "  tmux-resurrect              # Session restoration"
    log_info "  tmux-continuum              # Continuous saving"
    log_info "  tmux-yank                   # System clipboard integration"
    log_info "  catppuccin                  # Beautiful theme"
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current configuration:"
        log_info "  tmux version: $(tmux -V 2>/dev/null || echo 'not available')"
        log_info "  TPM location: $HOME/.tmux/plugins/tpm"
        log_info "  Plugins directory: $HOME/.tmux/plugins"
        local plugin_count
        plugin_count=$(find "$HOME/.tmux/plugins" -maxdepth 1 -type d ! -path "$HOME/.tmux/plugins" 2>/dev/null | wc -l || echo 0)
        log_info "  Installed plugins: $plugin_count"
    fi
    log_info ""
    log_info "Getting started:"
    log_info "  1. Start tmux: tmux"
    log_info "  2. Install plugins: prefix + I"
    log_info "  3. Configure plugins in ~/.tmux.conf"
    log_info ""
    log_info "Note: Default prefix key is Ctrl-b. Check your tmux.conf for custom prefix."
}

# Run main function
main "$@"
