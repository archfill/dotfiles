#!/usr/bin/env bash

# Go SDK installation script using mise (Polyglot version manager)
# This script installs Go via mise for unified version management
# Migrated from 'g' version manager in 2025年12月

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

log_info "Starting Go SDK setup via mise (Polyglot version manager)..."

# =============================================================================
# mise Environment and Go Management Functions
# =============================================================================

# Check mise environment for Go management
check_mise_environment() {
    log_info "Checking mise environment for Go management..."

    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise is not installed. Please install mise first."
        log_info "Run: curl https://mise.run | sh"
        return 1
    fi

    local mise_version
    mise_version=$(mise --version 2>/dev/null | head -1)
    log_info "mise version: $mise_version"

    # Check if Go is available via mise
    if mise which go >/dev/null 2>&1; then
        local go_path
        go_path=$(mise which go 2>/dev/null)
        log_info "Go managed by mise: $go_path"
    else
        log_info "Go not yet installed via mise"
    fi

    return 0
}

# Check Go installation status
check_go_status() {
    log_info "Checking Go installation status..."

    # Check Go command availability
    if ! command -v go >/dev/null 2>&1; then
        log_info "Go not installed"
        return 1
    fi

    # Get Go version information
    local go_version
    go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "unknown")
    log_info "Go version: $go_version"

    # Check Go environment
    if go env GOROOT >/dev/null 2>&1; then
        local goroot gopath
        goroot=$(go env GOROOT 2>/dev/null || echo "unknown")
        gopath=$(go env GOPATH 2>/dev/null || echo "unknown")
        log_info "GOROOT: $goroot"
        log_info "GOPATH: $gopath"
    fi

    # Check if Go version is recent (1.21+)
    local major_minor
    major_minor=$(echo "$go_version" | cut -d. -f1,2)
    if [[ "$major_minor" > "1.20" ]]; then
        log_success "Go version is recent: $go_version"
    else
        log_warning "Go version may be outdated: $go_version"
    fi

    log_success "Go status check completed"
    return 0
}

# Install Go via mise
install_go_via_mise() {
    log_info "Installing Go via mise..."

    # Parse command line options
    parse_install_options "$@"

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Go via mise"
        return 0
    fi

    # Check mise availability
    if ! check_mise_environment; then
        return 1
    fi

    # Determine target version
    local target_version="${GO_VERSION:-latest}"
    log_info "Target Go version: $target_version"

    # Check if Go should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]]; then
        local current_version
        if command -v go >/dev/null 2>&1; then
            current_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
            local major_minor
            major_minor=$(echo "$current_version" | cut -d. -f1,2)
            if [[ "$major_minor" > "1.20" ]]; then
                log_skip_reason "Go $current_version" "Already installed with recent version"
                return 0
            fi
        fi
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install Go via mise (Go is core, no plugin needed)
        log_info "Installing Go $target_version via mise..."

        if mise use -g "go@${target_version}" 2>/dev/null; then
            log_success "Go installed successfully via mise"

            # Verify installation
            local installed_version
            installed_version=$(mise which go >/dev/null 2>&1 && go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
            log_info "Installed Go version: $installed_version"
        else
            log_error "Failed to install Go via mise"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Go $target_version via mise"
    fi

    return 0
}

# Setup Go environment
setup_go_environment() {
    log_info "Setting up Go environment..."

    # Set Go environment variables (defaults)
    export GOPATH="${GOPATH:-$HOME/go}"
    export GOBIN="$GOPATH/bin"

    # Create Go workspace directories
    mkdir -p "$GOPATH/src" "$GOPATH/pkg" "$GOBIN"

    # Add GOBIN to PATH
    if [[ ":$PATH:" != *":$GOBIN:"* ]]; then
        export PATH="$GOBIN:$PATH"
    fi

    log_info "GOPATH: $GOPATH"
    log_info "GOBIN: $GOBIN"

    # Show mise-managed Go location
    if command -v mise >/dev/null 2>&1 && mise which go >/dev/null 2>&1; then
        local go_location
        go_location=$(mise which go 2>/dev/null)
        log_info "Go location (mise): $go_location"

        local go_root
        go_root=$(go env GOROOT 2>/dev/null)
        log_info "GOROOT: $go_root"
    fi
}

# Install useful Go tools
install_go_tools() {
    log_info "Installing useful Go tools..."

    # Parse command line options
    parse_install_options "$@"

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install useful Go tools"
        return 0
    fi

    # Skip tools installation if in container environment or CI
    if [[ -n "${CONTAINER:-}" || -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
        log_info "Skipping Go tools installation in container/CI environment"
        return 0
    fi

    # Ensure Go is available
    if ! command -v go >/dev/null 2>&1; then
        log_warning "Go not found in PATH, skipping tools installation"
        return 1
    fi

    # Ensure GOBIN is in PATH
    if [[ -n "${GOBIN:-}" ]] && [[ ":$PATH:" != *":$GOBIN:"* ]]; then
        export PATH="$GOBIN:$PATH"
    fi

    # List of essential Go tools
    local tools_info=(
        "golang.org/x/tools/cmd/goimports@latest:Import management tool"
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest:Comprehensive linter"
        "honnef.co/go/tools/cmd/staticcheck@latest:Static analysis tool"
        "github.com/go-delve/delve/cmd/dlv@latest:Go debugger"
    )

    local installed_count=0
    local skipped_count=0
    local failed_count=0

    for tool_info in "${tools_info[@]}"; do
        local tool_package tool_desc tool_name
        tool_package=$(echo "$tool_info" | cut -d: -f1)
        tool_desc=$(echo "$tool_info" | cut -d: -f2)
        tool_name=$(basename "${tool_package%@*}")

        # Skip if tool is already available
        if [[ "$FORCE_INSTALL" != "true" ]] && command -v "$tool_name" >/dev/null 2>&1; then
            log_skip_reason "$tool_name" "Already installed"
            ((skipped_count++))
            continue
        fi

        log_info "Installing $tool_name ($tool_desc)..."

        if [[ "$DRY_RUN" != "true" ]]; then
            if go install "$tool_package" >/dev/null 2>&1; then
                log_success "$tool_name installed successfully"
                ((installed_count++))
            else
                log_warning "Failed to install $tool_name (this is not critical)"
                ((failed_count++))
            fi
        else
            log_info "[DRY RUN] Would install $tool_name"
            ((installed_count++))
        fi
    done

    log_info "Go tools installation summary:"
    log_info "  Installed: $installed_count"
    log_info "  Skipped: $skipped_count"
    log_info "  Failed: $failed_count"

    log_success "Go tools installation completed"
    return 0
}

# Verify Go installation
verify_go_installation() {
    log_info "Verifying Go installation..."

    # Setup environment
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
        return 1
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

        rm -rf "$test_dir"
        mkdir -p "$test_dir"
        cd "$test_dir"

        if go mod init test-module >/dev/null 2>&1 && [[ -f "go.mod" ]]; then
            log_success "Go modules working correctly"
        else
            log_warning "Go modules test failed (not critical)"
        fi

        cd "$original_dir"
        rm -rf "$test_dir"
    fi
}

# Cleanup old g installation
cleanup_old_g_installation() {
    log_info "Checking for old g (Go version manager) installation..."

    # Remove g directory if it exists
    if [[ -d "$HOME/.g" ]]; then
        log_info "Removing old g installation: $HOME/.g"
        rm -rf "$HOME/.g"
        log_success "Old g installation removed"
    fi

    # Note: .zshenv configuration will be updated separately
    log_info "g cleanup completed"
}

# Main installation function
main() {
    log_info "Go SDK Setup via mise (Polyglot Version Manager)"
    log_info "================================================"

    # Parse command line options
    parse_install_options "$@"

    # Check if Go installation should be skipped
    if should_skip_installation_advanced "Go" "go" "latest" "version"; then
        log_info "Go is installed, checking mise environment and tools..."

        # Perform environment check
        check_mise_environment
        check_go_status

        # Setup/verify environment
        setup_go_environment

        # Setup workspace
        if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
            setup_go_workspace
        fi

        # Install useful tools
        install_go_tools "$@"

        # Verify installation
        if [[ "$DRY_RUN" != "true" ]]; then
            verify_go_installation || log_warning "Go verification had minor issues"
        fi

        return 0
    fi

    # Install Go via mise
    if ! install_go_via_mise "$@"; then
        log_error "Go installation failed"
        return 1
    fi

    # Setup environment
    setup_go_environment

    # Setup workspace
    if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
        setup_go_workspace
    fi

    # Install useful tools
    install_go_tools "$@"

    # Cleanup old g installation (optional, after successful mise setup)
    if [[ "$DRY_RUN" != "true" ]]; then
        cleanup_old_g_installation
    fi

    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_go_installation || log_warning "Go verification had minor issues"
    fi

    log_success "Go SDK setup completed!"
    log_info ""
    log_info "mise commands for Go:"
    log_info "  mise list go           # List installed Go versions"
    log_info "  mise use go@<version>  # Install and use specific version"
    log_info "  mise use -g go@latest  # Set global Go version"
    log_info "  mise where go          # Show Go installation path"
    log_info ""
    log_info "Go environment:"
    log_info "  go version             # Show Go version"
    log_info "  go env                 # Show Go environment variables"
    log_info "  go mod init <name>     # Initialize new Go module"
    log_info ""
    log_info "Installed tools:"
    log_info "  goimports              # Import management"
    log_info "  golangci-lint          # Comprehensive linter"
    log_info "  staticcheck            # Static analysis"
    log_info "  dlv                    # Go debugger"
    log_info ""
    log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"
