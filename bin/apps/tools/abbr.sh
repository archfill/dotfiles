#!/usr/bin/env bash

# zsh-abbr (zsh abbreviations manager) installation and configuration management script
# This script installs zsh-abbr for managing shell abbreviations

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting zsh-abbr (abbreviations manager) setup..."

# Check zsh-abbr installation
check_abbr_environment() {
    log_info "Checking zsh-abbr environment..."

    if ! is_command_available "abbr" "--version"; then
        log_info "abbr not available"
        return 1
    fi

    log_success "zsh-abbr environment checks passed"
    return 0
}

# Check zsh-abbr version requirements
check_abbr_version_requirements() {
    local required_version="${ABBR_VERSION:-5.0.0}"

    log_info "Checking zsh-abbr version requirements (>= $required_version)..."

    if ! command -v abbr >/dev/null 2>&1; then
        log_info "abbr command not available"
        return 1
    fi

    # abbr version output format: "abbr version 5.6.0"
    local current_version
    current_version=$(abbr --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine zsh-abbr version"
        return 1
    fi

    compare_versions "$current_version" "$required_version"
    local result=$?

    case $result in
        0|2)  # current >= required
            log_success "zsh-abbr version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "zsh-abbr version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for zsh-abbr"
            return 1
            ;;
    esac
}

# Install zsh-abbr
install_abbr() {
    log_info "Installing zsh-abbr..."

    # Parse command line options
    parse_install_options "$@"

    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install zsh-abbr"
        return 0
    fi

    local distro="$(get_os_distribution)"
    local os_name="$(uname -s)"

    if [[ "$DRY_RUN" != "true" ]]; then
        case "$os_name" in
            Darwin)
                log_info "Installing zsh-abbr via Homebrew on macOS..."
                if command -v brew >/dev/null 2>&1; then
                    brew install olets/tap/zsh-abbr
                    log_success "zsh-abbr installed successfully"
                else
                    log_error "Homebrew not found. Please install Homebrew first."
                    return 1
                fi
                ;;

            Linux)
                case "$distro" in
                    arch)
                        log_info "Installing zsh-abbr via AUR on Arch Linux..."
                        if command -v yay >/dev/null 2>&1; then
                            yay -S --noconfirm zsh-abbr
                            log_success "zsh-abbr installed successfully"
                        else
                            log_warning "yay not found, installing via manual method..."
                            install_abbr_manual
                        fi
                        ;;

                    debian|ubuntu|*)
                        log_info "Installing zsh-abbr manually (no package available)..."
                        install_abbr_manual
                        ;;
                esac
                ;;

            *)
                log_error "Unsupported OS: $os_name"
                return 1
                ;;
        esac

        # Verify installation
        if command -v abbr >/dev/null 2>&1; then
            log_info "zsh-abbr version: $(abbr --version 2>/dev/null || echo 'installed')"
        else
            log_warning "abbr command not immediately available (may require shell restart)"
        fi
    else
        log_info "[DRY RUN] Would install zsh-abbr for $os_name ($distro)"
    fi
}

# Manual installation method
install_abbr_manual() {
    log_info "Installing zsh-abbr from GitHub (manual method)..."

    # Create installation directory
    local install_dir="${ZDOTDIR:-$HOME}/.zsh/plugins"
    mkdir -p "$install_dir"

    # Clone repository
    local abbr_dir="$install_dir/zsh-abbr"

    if [[ -d "$abbr_dir" ]]; then
        log_info "Updating existing zsh-abbr installation..."
        pushd "$abbr_dir" >/dev/null
        git pull origin main
        popd >/dev/null
    else
        log_info "Cloning zsh-abbr repository..."
        git clone https://github.com/olets/zsh-abbr.git "$abbr_dir"
    fi

    if [[ -d "$abbr_dir" ]]; then
        log_success "zsh-abbr installed to: $abbr_dir"
        log_info ""
        log_info "To enable zsh-abbr, add to your .zshrc:"
        log_info "  source $abbr_dir/zsh-abbr.zsh"
        log_info ""
        log_info "Or add to your Sheldon config (.config/sheldon/plugins.toml):"
        log_info "  [plugins.zsh-abbr]"
        log_info "  github = \"olets/zsh-abbr\""
        return 0
    else
        log_error "Failed to install zsh-abbr"
        return 1
    fi
}

# Setup zsh-abbr via Sheldon plugin manager
setup_abbr_sheldon() {
    log_info "Setting up zsh-abbr via Sheldon..."

    # Parse command line options
    parse_install_options "$@"

    local sheldon_config="$HOME/.config/sheldon/plugins.toml"

    if [[ ! -f "$sheldon_config" ]]; then
        log_warning "Sheldon config not found: $sheldon_config"
        log_info "Skipping Sheldon integration"
        return 1
    fi

    # Check if zsh-abbr is already configured
    if grep -q "zsh-abbr" "$sheldon_config" 2>/dev/null; then
        log_skip_reason "zsh-abbr Sheldon integration" "Already configured"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Adding zsh-abbr to Sheldon plugins..."

        # Backup config
        cp "$sheldon_config" "${sheldon_config}.backup.$(date +%Y%m%d_%H%M%S)"

        # Add plugin configuration
        cat >> "$sheldon_config" << 'EOF'

# zsh-abbr - Manage abbreviations for faster command input
[plugins.zsh-abbr]
github = "olets/zsh-abbr"
EOF

        log_success "zsh-abbr added to Sheldon configuration"
        log_info "Run 'sheldon lock --update' to install the plugin"
    else
        log_info "[DRY RUN] Would add zsh-abbr to Sheldon configuration"
    fi
}

# Main installation function
main() {
    log_info "zsh-abbr (Abbreviations Manager) Setup"
    log_info "======================================"

    # Parse command line options
    parse_install_options "$@"

    # Get target abbr version
    local abbr_version="${ABBR_VERSION:-5.0.0}"

    # Check if zsh-abbr installation should be skipped
    if should_skip_installation_advanced "zsh-abbr" "abbr" "$abbr_version" "--version"; then
        log_info "zsh-abbr is already installed"
        check_abbr_version_requirements
        return 0
    fi

    # Install zsh-abbr
    install_abbr "$@"

    # Setup Sheldon integration if available
    if command -v sheldon >/dev/null 2>&1; then
        setup_abbr_sheldon "$@"
    fi

    log_success "zsh-abbr setup completed!"
    log_info ""
    log_info "Available abbr commands:"
    log_info "  abbr add <abbr>=<expansion>  # Add new abbreviation"
    log_info "  abbr add --global <abbr>     # Add global abbreviation"
    log_info "  abbr erase <abbr>            # Remove abbreviation"
    log_info "  abbr list                    # List all abbreviations"
    log_info "  abbr import-aliases          # Import from aliases"
    log_info ""
    log_info "Example usage:"
    log_info "  abbr add g=git"
    log_info "  abbr add gc='git commit'"
    log_info "  abbr add gp='git push'"
    log_info ""
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Current status:"
        if command -v abbr >/dev/null 2>&1; then
            log_info "  abbr version: $(abbr --version 2>/dev/null || echo 'installed')"
            log_info "  Abbreviations count: $(abbr list 2>/dev/null | wc -l || echo '0')"
        else
            log_info "  abbr command: not immediately available (restart shell)"
        fi
    fi
    log_info ""
    log_info "Documentation: https://zsh-abbr.olets.dev/"
    log_info ""
    log_info "Note: Restart your shell or run 'source ~/.zshrc' to use abbr"
}

# Run main function
main "$@"
