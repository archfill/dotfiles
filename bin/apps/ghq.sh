#!/usr/bin/env bash

# Git repository management tool (ghq) installation and configuration script
# This script installs ghq and sets up comprehensive repository management

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

log_info "Starting ghq (Git repository management tool) setup..."

# =============================================================================
# Enhanced Configuration and Version Checking Functions
# =============================================================================

# Check ghq git configuration
check_ghq_git_config() {
    log_info "Checking ghq git configuration..."
    
    local ghq_root_configured
    ghq_root_configured=$(git config --global ghq.root 2>/dev/null || echo "")
    
    if [[ -n "$ghq_root_configured" ]]; then
        log_info "ghq.root configured: $ghq_root_configured"
        
        # Verify the directory exists
        if [[ -d "$ghq_root_configured" ]]; then
            log_success "ghq root directory exists: $ghq_root_configured"
            return 0
        else
            log_warning "ghq root directory does not exist: $ghq_root_configured (will be created when needed)"
            return 0
        fi
    else
        log_info "ghq.root not configured (will use default)"
        return 0
    fi
}

# Check ghq version requirements
check_ghq_version_requirements() {
    local command_name="ghq"
    local required_version="${GHQ_VERSION:-1.3.0}"
    
    log_info "Checking ghq version requirements (>= $required_version)..."
    
    if ! is_command_available "$command_name" "--version"; then
        return 1
    fi
    
    # ghq version output format: "ghq version 1.4.2 (rev:abc123)"
    local current_version
    current_version=$(ghq --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine ghq version"
        return 1
    fi
    
    compare_versions "$current_version" "$required_version"
    local result=$?
    
    case $result in
        0|2)  # current >= required
            log_success "ghq version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "ghq version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for ghq"
            return 1
            ;;
    esac
}

# Check repository management status
check_repository_management_status() {
    log_info "Checking repository management status..."
    
    local ghq_root
    ghq_root=$(git config --global ghq.root 2>/dev/null || echo "$HOME/git")
    
    if [[ ! -d "$ghq_root" ]]; then
        log_info "Repository root does not exist: $ghq_root (will be created when repositories are cloned)"
        return 0
    fi
    
    # Count managed repositories
    local repo_count=0
    if command -v ghq >/dev/null 2>&1; then
        repo_count=$(ghq list 2>/dev/null | wc -l || echo 0)
        log_info "Managed repositories: $repo_count"
        
        if (( repo_count > 0 )); then
            log_info "Recent repositories:"
            ghq list 2>/dev/null | head -5 || true
        fi
    fi
    
    # Check for Git repositories in root that might not be managed by ghq
    local unmanaged_repos=0
    if [[ -d "$ghq_root" ]]; then
        # Find .git directories and count them
        unmanaged_repos=$(find "$ghq_root" -name ".git" -type d 2>/dev/null | wc -l || echo 0)
        
        if (( unmanaged_repos > repo_count )); then
            local diff=$((unmanaged_repos - repo_count))
            log_info "Potential unmanaged repositories: $diff"
        fi
    fi
    
    log_success "Repository management status check completed"
    return 0
}

# Comprehensive ghq environment check
check_ghq_environment() {
    log_info "Performing comprehensive ghq environment check..."
    
    local all_checks_passed=true
    
    # Check command availability and version
    if ! check_ghq_version_requirements; then
        all_checks_passed=false
    fi
    
    # Check git configuration
    if ! check_ghq_git_config; then
        log_info "ghq git configuration needs setup"
        all_checks_passed=false
    fi
    
    # Check repository management status
    check_repository_management_status
    
    # Check PATH configuration
    local ghq_in_path=true
    if ! command -v ghq >/dev/null 2>&1; then
        ghq_in_path=false
        all_checks_passed=false
        log_warning "ghq not found in PATH"
        
        # Check if ghq exists in common locations
        local common_locations=(
            "$HOME/.local/bin/ghq"
            "/usr/local/bin/ghq"
            "$(go env GOPATH 2>/dev/null)/bin/ghq"
        )
        
        for location in "${common_locations[@]}"; do
            if [[ -n "$location" && -x "$location" ]]; then
                log_info "Found ghq at: $location"
                break
            fi
        done
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All ghq environment checks passed"
        return 0
    else
        log_info "Some ghq environment checks failed"
        return 1
    fi
}

# Function to install ghq on different platforms
install_ghq() {
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        "Darwin")
            if command -v brew >/dev/null 2>&1; then
                log_info "Installing ghq via Homebrew..."
                brew install ghq
            else
                log_error "Homebrew not found on macOS"
                exit 1
            fi
            ;;
        "Linux"|"Linux_WSL")
            if command -v go >/dev/null 2>&1; then
                log_info "Installing ghq via go install..."
                go install github.com/x-motemen/ghq@latest
            else
                log_info "Go not found, installing ghq binary..."
                install_ghq_binary_linux
            fi
            ;;
        "Termux")
            log_info "Installing ghq via pkg (Termux)..."
            pkg install ghq
            ;;
        "Cygwin")
            log_info "Installing ghq binary for Cygwin..."
            install_ghq_binary_linux
            ;;
        *)
            log_warning "Unsupported platform: $platform"
            log_info "Attempting to install ghq binary..."
            install_ghq_binary_linux
            ;;
    esac
}

# Function to install ghq binary on Linux-like systems
install_ghq_binary_linux() {
    local ghq_version
    local arch
    local os
    local download_url
    local install_dir="$HOME/.local/bin"
    
    # Get latest version and assets from GitHub API
    log_info "Fetching latest ghq version from GitHub..."
    local api_response
    api_response=$(curl -s --connect-timeout 10 "https://api.github.com/repos/x-motemen/ghq/releases/latest" 2>/dev/null)
    
    ghq_version=$(echo "$api_response" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 2>/dev/null)
    
    if [[ -z "$ghq_version" ]]; then
        # Fallback to known version
        ghq_version="v1.6.2"
        log_info "API fetch failed, using fallback version: $ghq_version"
    else
        log_info "Latest ghq version: $ghq_version"
    fi
    
    # Detect architecture
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        i386|i686) arch="386" ;;
        armv7l) arch="arm" ;;
        aarch64|arm64) arch="arm64" ;;
        *) 
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    
    # Detect OS
    case "$(uname -s)" in
        Linux*) os="linux" ;;
        Darwin*) os="darwin" ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *)
            log_error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
    
    # Debug: Show detected platform info
    log_info "Detected OS: $os, Architecture: $arch"
    
    # Find the correct asset name from the API response
    local asset_name
    if [[ -n "$api_response" ]]; then
        # Debug: Show available assets
        log_info "Available assets in release:"
        local all_assets
        all_assets=$(echo "$api_response" | grep -o '"name": "[^"]*"' | cut -d'"' -f4 | grep -E '\.(tar\.gz|zip|tar\.xz)$' | head -10)
        
        if [[ -n "$all_assets" ]]; then
            echo "$all_assets"
        else
            log_info "No archive assets found, showing all assets:"
            echo "$api_response" | grep -o '"name": "[^"]*"' | cut -d'"' -f4 | head -10
        fi
        
        # Debug: Show what we're looking for
        log_info "Looking for assets matching OS='$os' and ARCH='$arch'"
        
        # Try to find the correct asset name from the release (more flexible patterns)
        # First try exact pattern: ghq_linux_amd64.zip
        log_info "Trying pattern: ghq_${os}_${arch}.zip"
        asset_name=$(echo "$api_response" | grep -o '"name": "ghq_'"${os}"'_'"${arch}"'\.zip"' | cut -d'"' -f4 | head -1)
        
        if [[ -n "$asset_name" ]]; then
            log_info "Matched exact ZIP pattern: $asset_name"
        else
            log_info "No match for exact ZIP pattern, trying tar.gz..."
            # Try tar.gz with same pattern
            asset_name=$(echo "$api_response" | grep -o '"name": "ghq_'"${os}"'_'"${arch}"'\.tar\.gz"' | cut -d'"' -f4 | head -1)
            
            if [[ -n "$asset_name" ]]; then
                log_info "Matched exact tar.gz pattern: $asset_name"
            else
                log_info "No match for exact tar.gz pattern, trying dash pattern..."
                # Try with dashes: ghq-linux-amd64.zip
                asset_name=$(echo "$api_response" | grep -o '"name": "ghq-'"${os}"'-'"${arch}"'\.zip"' | cut -d'"' -f4 | head -1)
                
                if [[ -n "$asset_name" ]]; then
                    log_info "Matched dash ZIP pattern: $asset_name"
                else
                    log_info "No match for dash pattern, trying flexible pattern..."
                    # Try any pattern with os and arch
                    asset_name=$(echo "$api_response" | grep -o '"name": "[^"]*'"${os}"'[^"]*'"${arch}"'[^"]*\.zip"' | cut -d'"' -f4 | head -1)
                    
                    if [[ -n "$asset_name" ]]; then
                        log_info "Matched flexible ZIP pattern: $asset_name"
                    else
                        log_info "No ZIP match, trying tar.gz flexible pattern..."
                        # Try tar.gz versions
                        asset_name=$(echo "$api_response" | grep -o '"name": "[^"]*'"${os}"'[^"]*'"${arch}"'[^"]*\.tar\.gz"' | cut -d'"' -f4 | head -1)
                        
                        if [[ -n "$asset_name" ]]; then
                            log_info "Matched flexible tar.gz pattern: $asset_name"
                        fi
                    fi
                fi
            fi
        fi
    else
        log_warning "No API response available for asset detection"
    fi
    
    if [[ -z "$asset_name" ]]; then
        # Use fallback naming pattern (try multiple formats)
        local fallback_patterns=(
            "ghq_${os}_${arch}.tar.gz"
            "ghq_${os}_${arch}.zip"
            "ghq-${os}-${arch}.tar.gz"
            "ghq-${os}-${arch}.zip"
        )
        
        asset_name="${fallback_patterns[0]}"  # Default to first pattern
        log_info "Could not find asset name in API response, using pattern: $asset_name"
    else
        log_info "Found asset name: $asset_name"
    fi
    
    download_url="https://github.com/x-motemen/ghq/releases/download/${ghq_version}/${asset_name}"
    
    log_info "Downloading ghq from: $download_url"
    
    # Create install directory
    mkdir -p "$install_dir"
    
    # Download and extract
    local temp_file
    temp_file=$(mktemp)
    
    # Try multiple download patterns if the first one fails
    local download_success=false
    local alternative_patterns=(
        "ghq_${os}_${arch}.tar.gz"
        "ghq_${os}_${arch}.zip"
        "ghq-${os}-${arch}.tar.gz"
        "ghq-${os}-${arch}.zip"
        "ghq-${ghq_version}-${os}-${arch}.tar.gz"
        "ghq-${ghq_version}-${os}-${arch}.zip"
        "ghq_${ghq_version}_${os}_${arch}.tar.gz"
        "ghq_${ghq_version}_${os}_${arch}.zip"
    )
    
    # Try the discovered asset name first
    log_info "Attempting primary download from: $download_url"
    if curl -fsSL "$download_url" -o "$temp_file" 2>/dev/null && [[ -s "$temp_file" ]]; then
        download_success=true
        log_info "Primary download successful"
    else
        log_info "Primary download failed, trying alternative patterns..."
        
        # Try alternative patterns
        for pattern in "${alternative_patterns[@]}"; do
            local alt_url="https://github.com/x-motemen/ghq/releases/download/${ghq_version}/${pattern}"
            log_info "Trying: $alt_url"
            
            if curl -fsSL "$alt_url" -o "$temp_file" 2>/dev/null && [[ -s "$temp_file" ]]; then
                download_success=true
                download_url="$alt_url"
                log_info "Alternative download successful: $pattern"
                break
            else
                log_info "Failed: $pattern"
            fi
        done
    fi
    
    if [[ "$download_success" == "true" ]]; then
        log_info "Verifying downloaded file..."
        
        # Verify and extract the downloaded file
        local file_type
        file_type=$(file "$temp_file")
        log_info "File type: $file_type"
        
        if echo "$file_type" | grep -q "gzip compressed"; then
            log_info "Processing tar.gz file..."
            extract_archive_tar_gz "$temp_file" "$install_dir"
        elif echo "$file_type" | grep -q "Zip archive"; then
            log_info "Processing ZIP file..."
            extract_archive_zip "$temp_file" "$install_dir"
        elif echo "$file_type" | grep -q "XZ compressed"; then
            log_info "Processing tar.xz file..."
            extract_archive_tar_xz "$temp_file" "$install_dir"
        else
            log_error "Unsupported file format: $file_type"
            head -n 5 "$temp_file"
            exit 1
        fi
    else
        log_error "Failed to download ghq from all attempted URLs"
        log_info "Attempted URLs:"
        log_info "  $download_url"
        for pattern in "${alternative_patterns[@]}"; do
            log_info "  https://github.com/x-motemen/ghq/releases/download/${ghq_version}/${pattern}"
        done
        exit 1
    fi
    
    rm -f "$temp_file"
}

# Extract tar.gz archive
extract_archive_tar_gz() {
    local archive_file="$1"
    local install_dir="$2"
    
    # Try direct extraction first
    if tar -xzf "$archive_file" -C "$install_dir" --strip-components=1 --wildcards "*/ghq" 2>/dev/null; then
        chmod +x "$install_dir/ghq"
        log_success "ghq binary installed to $install_dir/ghq"
        return 0
    fi
    
    # Try alternative method
    extract_to_temp_and_find "$archive_file" "$install_dir" "tar -xzf"
}

# Extract ZIP archive
extract_archive_zip() {
    local archive_file="$1"
    local install_dir="$2"
    
    if ! command -v unzip >/dev/null 2>&1; then
        log_error "unzip command not found, cannot extract ZIP files"
        exit 1
    fi
    
    log_info "Extracting ZIP archive..."
    
    # Create temporary directory for extraction
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Extract ZIP file
    if unzip -q "$archive_file" -d "$temp_dir" 2>/dev/null; then
        log_info "ZIP archive extracted to temporary directory"
        
        # Find ghq binary
        local ghq_binary
        ghq_binary=$(find "$temp_dir" -name "ghq" -type f | head -1)
        
        if [[ -n "$ghq_binary" ]]; then
            log_info "Found ghq binary at: $ghq_binary"
            cp "$ghq_binary" "$install_dir/ghq"
            chmod +x "$install_dir/ghq"
            log_success "ghq binary installed to $install_dir/ghq"
            rm -rf "$temp_dir"
            return 0
        else
            log_error "ghq binary not found in ZIP archive"
            log_info "Archive contents:"
            find "$temp_dir" -type f | head -10
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        log_error "Failed to extract ZIP archive"
        log_info "Trying with verbose unzip for debugging..."
        unzip -l "$archive_file"
        rm -rf "$temp_dir"
        exit 1
    fi
}

# Extract tar.xz archive
extract_archive_tar_xz() {
    local archive_file="$1"
    local install_dir="$2"
    
    # Try direct extraction first
    if tar -xJf "$archive_file" -C "$install_dir" --strip-components=1 --wildcards "*/ghq" 2>/dev/null; then
        chmod +x "$install_dir/ghq"
        log_success "ghq binary installed to $install_dir/ghq"
        return 0
    fi
    
    # Try alternative method
    extract_to_temp_and_find "$archive_file" "$install_dir" "tar -xJf"
}

# Common extraction to temp directory and find binary
extract_to_temp_and_find() {
    local archive_file="$1"
    local install_dir="$2"
    local extract_cmd="$3"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Handle different extraction commands
    local success=false
    if [[ "$extract_cmd" == "unzip -q" ]]; then
        if unzip -q "$archive_file" -d "$temp_dir" 2>/dev/null; then
            success=true
        fi
    else
        if $extract_cmd "$archive_file" -C "$temp_dir" 2>/dev/null; then
            success=true
        fi
    fi
    
    if [[ "$success" == "true" ]]; then
        log_info "Archive extracted to temporary directory"
        
        # Find ghq binary
        local ghq_binary
        ghq_binary=$(find "$temp_dir" -name "ghq" -type f | head -1)
        
        if [[ -n "$ghq_binary" ]]; then
            log_info "Found ghq binary at: $ghq_binary"
            cp "$ghq_binary" "$install_dir/ghq"
            chmod +x "$install_dir/ghq"
            log_success "ghq binary installed to $install_dir/ghq"
            rm -rf "$temp_dir"
            return 0
        else
            log_error "ghq binary not found in archive"
            log_info "Archive contents:"
            find "$temp_dir" -type f | head -10
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        log_error "Failed to extract archive with command: $extract_cmd"
        rm -rf "$temp_dir"
        exit 1
    fi
}

# Enhanced function to setup ghq configuration
setup_ghq_config() {
    log_info "Setting up ghq configuration..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Get ghq root from configuration or use default
    local ghq_root="${GHQ_ROOT:-$HOME/git}"
    
    # Check if configuration is already up to date
    if [[ "$FORCE_INSTALL" != "true" ]] && check_ghq_git_config; then
        local current_root
        current_root=$(git config --global ghq.root 2>/dev/null)
        if [[ "$current_root" == "$ghq_root" ]]; then
            log_skip_reason "ghq configuration" "Already configured with correct root: $current_root"
            return 0
        fi
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would configure ghq.root to $ghq_root"
        return 0
    fi
    
    # Create ghq root directory
    execute_if_not_dry_run "Create ghq root directory" mkdir -p "$ghq_root"
    
    # Set git config for ghq
    log_info "Setting ghq.root to $ghq_root"
    execute_if_not_dry_run "Configure ghq.root" git config --global ghq.root "$ghq_root"
    
    # Setup additional ghq configurations
    if [[ "$DRY_RUN" != "true" ]]; then
        # Set default import strategy
        git config --global ghq.shallow true
        log_info "Configured ghq.shallow=true for faster clones"
        
        # Set lookup depth (optional)
        git config --global ghq.look.depth 1
        log_info "Configured ghq.look.depth=1 for better performance"
    fi
    
    # Verify configuration
    if [[ "$DRY_RUN" != "true" ]]; then
        local configured_root
        configured_root=$(git config --global ghq.root)
        if [[ "$configured_root" == "$ghq_root" ]]; then
            log_success "ghq.root configured successfully: $configured_root"
            
            # Show all ghq-related git configs
            log_info "Current ghq git configurations:"
            git config --global --get-regexp '^ghq\.' || log_info "  No additional ghq configurations found"
        else
            log_error "Failed to configure ghq.root"
            return 1
        fi
    fi
}

# Function to verify ghq installation
verify_ghq_installation() {
    log_info "Verifying ghq installation..."
    
    # Add .local/bin to PATH for current session if not already present
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        log_info "Added $HOME/.local/bin to PATH for current session"
    fi
    
    # Check if ghq binary exists
    local ghq_path="$HOME/.local/bin/ghq"
    if [[ -f "$ghq_path" ]]; then
        log_info "ghq binary found at: $ghq_path"
        
        # Make sure it's executable
        if [[ -x "$ghq_path" ]]; then
            log_info "ghq binary is executable"
        else
            log_warning "ghq binary is not executable, fixing permissions..."
            chmod +x "$ghq_path"
        fi
    else
        log_warning "ghq binary not found at expected location: $ghq_path (may be installed elsewhere)"
        if command -v ghq >/dev/null 2>&1; then
            log_info "ghq found in system PATH: $(which ghq)"
        else
            return 1
        fi
    fi
    
    if command -v ghq >/dev/null 2>&1; then
        local version
        version=$(ghq --version)
        log_success "ghq installed successfully: $version"
        
        # Show current configuration
        log_info "Current ghq configuration:"
        echo "  ghq.root: $(git config --global ghq.root)"
        
        # Show usage examples
        log_info "Usage examples:"
        echo "  ghq get github.com/user/repo    # Clone repository"
        echo "  ghq list                         # List repositories"
        echo "  ghq root                         # Show root directory"
        echo "  g                                # Interactive project selection (zsh function)"
        
        log_info "Note: ghq will be available in new shell sessions via dotfiles configuration"
        
        return 0
    else
        log_error "ghq verification failed - command not found in PATH"
        log_info "ghq will be available after dotfiles setup completes"
        return 1
    fi
}

# Main installation and setup function
main() {
    log_info "ghq (Git Repository Management Tool) Setup"
    log_info "=========================================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if ghq installation should be skipped
    local required_version="${GHQ_VERSION:-1.3.0}"
    if should_skip_installation_advanced "ghq" "ghq" "$required_version" "--version"; then
        # Even if ghq is installed, check and update configuration
        log_info "ghq is installed, checking configuration and environment..."
        
        # Perform comprehensive environment check
        check_ghq_environment
        
        # Setup/verify configuration
        setup_ghq_config "$@"
        
        # Repository management optimization
        if [[ "$QUICK_CHECK" != "true" ]]; then
            optimize_repository_management "$@"
        fi
        
        verify_ghq_installation
        return 0
    fi
    
    # Install ghq
    execute_if_not_dry_run "Install ghq via package manager" install_ghq
    
    # Setup configuration
    setup_ghq_config "$@"
    
    # Setup environment
    setup_ghq_environment
    
    # Repository management optimization (skip in quick mode)
    if [[ "$QUICK_CHECK" != "true" ]]; then
        optimize_repository_management "$@"
    fi
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_ghq_installation
    fi
    
    log_success "ghq setup completed successfully!"
    log_info ""
    log_info "Available ghq commands:"
    log_info "  ghq get <repo>           # Clone repository to managed location"
    log_info "  ghq list                 # List all managed repositories"
    log_info "  ghq look <repo>          # Navigate to repository directory"
    log_info "  ghq root                 # Show root directory"
    log_info "  ghq import <service>     # Import repositories from service"
    log_info ""
    log_info "Configuration:"
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "  ghq.root: $(git config --global ghq.root 2>/dev/null || echo 'not configured')"
        log_info "  ghq.shallow: $(git config --global ghq.shallow 2>/dev/null || echo 'not configured')"
        log_info "  ghq.look.depth: $(git config --global ghq.look.depth 2>/dev/null || echo 'not configured')"
    fi
    log_info ""
    log_info "Getting started:"
    log_info "  ghq get github.com/user/repo    # Clone a repository"
    log_info "  ghq list | head -5               # Show managed repositories"
    log_info "  g                                # Interactive repository selection (if configured)"
    log_info ""
    log_info "Note: Repository management commands will be available in new shell sessions"
}

# Enhanced environment setup
setup_ghq_environment() {
    log_info "Setting up ghq environment..."
    
    # Add .local/bin to PATH for current session if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        log_info "Added $HOME/.local/bin to PATH for current session"
    fi
    
    # Set environment variables for ghq
    local ghq_root="${GHQ_ROOT:-$HOME/git}"
    export GHQ_ROOT="$ghq_root"
    
    log_success "ghq environment setup completed"
}

# Repository management optimization
optimize_repository_management() {
    log_info "Optimizing repository management..."
    
    # Parse command line options
    parse_install_options "$@"
    
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would optimize repository management"
        return 0
    fi
    
    if ! command -v ghq >/dev/null 2>&1; then
        log_info "ghq not available, skipping repository optimization"
        return 0
    fi
    
    local ghq_root
    ghq_root=$(git config --global ghq.root 2>/dev/null || echo "$HOME/git")
    
    if [[ ! -d "$ghq_root" ]]; then
        log_info "Repository root does not exist, creating: $ghq_root"
        execute_if_not_dry_run "Create repository root" mkdir -p "$ghq_root"
    fi
    
    # Check for orphaned repositories (optional cleanup)
    if [[ "$DRY_RUN" != "true" && -d "$ghq_root" ]]; then
        local managed_count
        managed_count=$(ghq list 2>/dev/null | wc -l || echo 0)
        
        local total_repos
        total_repos=$(find "$ghq_root" -name ".git" -type d 2>/dev/null | wc -l || echo 0)
        
        if (( total_repos > managed_count )); then
            local unmanaged=$((total_repos - managed_count))
            log_info "Found $unmanaged potentially unmanaged repositories"
            log_info "Consider running 'ghq import' to manage existing repositories"
        fi
        
        log_success "Repository management optimization completed"
    fi
}

# Run main function
main "$@"