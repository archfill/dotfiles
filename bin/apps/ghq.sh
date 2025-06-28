#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/../lib/common.sh"

setup_error_handling

log_info "Installing ghq (Git repository management tool)..."

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
        
        # Try to find the correct asset name from the release (tar.gz first)
        asset_name=$(echo "$api_response" | grep -o '"name": "[^"]*'"${os}"'[^"]*'"${arch}"'[^"]*\.tar\.gz"' | cut -d'"' -f4 | head -1)
        
        if [[ -z "$asset_name" ]]; then
            # Try ZIP files
            asset_name=$(echo "$api_response" | grep -o '"name": "[^"]*'"${os}"'[^"]*'"${arch}"'[^"]*\.zip"' | cut -d'"' -f4 | head -1)
        fi
        
        if [[ -z "$asset_name" ]]; then
            # Try tar.xz files
            asset_name=$(echo "$api_response" | grep -o '"name": "[^"]*'"${os}"'[^"]*'"${arch}"'[^"]*\.tar\.xz"' | cut -d'"' -f4 | head -1)
        fi
        
        if [[ -z "$asset_name" ]]; then
            # Try any archive with os and arch in name
            asset_name=$(echo "$api_response" | grep -o '"name": "[^"]*'"${os}"'[^"]*'"${arch}"'[^"]*"' | grep -E '\.(tar\.gz|zip|tar\.xz)$' | cut -d'"' -f4 | head -1)
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
    
    extract_to_temp_and_find "$archive_file" "$install_dir" "unzip -q"
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
    
    if $extract_cmd "$archive_file" -C "$temp_dir" 2>/dev/null; then
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
        log_error "Failed to extract archive"
        rm -rf "$temp_dir"
        exit 1
    fi
}

# Function to setup ghq configuration
setup_ghq_config() {
    local ghq_root="$HOME/git"
    
    log_info "Setting up ghq configuration..."
    
    # Create ghq root directory
    mkdir -p "$ghq_root"
    
    # Set git config for ghq
    log_info "Setting ghq.root to $ghq_root"
    git config --global ghq.root "$ghq_root"
    
    # Verify configuration
    local configured_root
    configured_root=$(git config --global ghq.root)
    if [[ "$configured_root" == "$ghq_root" ]]; then
        log_success "ghq.root configured successfully: $configured_root"
    else
        log_error "Failed to configure ghq.root"
        exit 1
    fi
}

# Function to verify ghq installation
verify_ghq_installation() {
    log_info "Verifying ghq installation..."
    
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
        
        return 0
    else
        log_error "ghq verification failed - command not found"
        return 1
    fi
}

# Main execution
main() {
    # Check if ghq is already installed
    if command -v ghq >/dev/null 2>&1; then
        log_success "ghq is already installed: $(ghq --version)"
        setup_ghq_config
        verify_ghq_installation
        return 0
    fi
    
    # Install ghq
    install_ghq
    
    # Setup configuration
    setup_ghq_config
    
    # Verify installation
    verify_ghq_installation
    
    log_success "ghq setup completed successfully"
}

# Run main function
main "$@"