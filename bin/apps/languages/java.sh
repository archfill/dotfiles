#!/usr/bin/env bash

# mise (Polyglot version manager) - Java/Maven management script
# This script ensures Java and Maven are installed and managed by mise

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

log_info "Starting Java SDK setup via mise..."

# =============================================================================
# mise Java Management Functions
# =============================================================================

# Check mise installation
check_mise_environment() {
    log_info "Checking mise environment..."

    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise is not installed. Please install mise first."
        log_info "  brew install mise  # or see https://mise.jdx.dev"
        return 1
    fi

    local mise_version
    mise_version=$(mise --version 2>/dev/null | head -1 || echo "unknown")
    log_info "mise version: $mise_version"

    log_success "mise environment check passed"
    return 0
}

# Check Java installation status
check_java_status() {
    log_info "Checking Java installation status..."

    # Check if Java is available via mise
    if command -v java >/dev/null 2>&1; then
        local java_version
        java_version=$(java -version 2>&1 | head -1 || echo "unknown")
        log_info "Current Java: $java_version"

        # Check JAVA_HOME
        if [[ -n "${JAVA_HOME:-}" ]]; then
            log_info "JAVA_HOME: $JAVA_HOME"
        fi
    else
        log_info "No Java installation found"
    fi

    # List mise-managed Java versions
    if command -v mise >/dev/null 2>&1; then
        local java_versions
        java_versions=$(mise list java 2>/dev/null | grep -v "No versions" || echo "none")
        if [[ "$java_versions" != "none" && -n "$java_versions" ]]; then
            log_info "mise-managed Java versions:"
            echo "$java_versions" | while read -r line; do
                log_info "  $line"
            done
        fi
    fi

    log_success "Java status check completed"
    return 0
}

# Check build tools status
check_build_tools_status() {
    log_info "Checking Java build tools status..."

    local installed_tools=0

    # Maven
    if command -v mvn >/dev/null 2>&1; then
        local mvn_version
        mvn_version=$(mvn -version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_info "Maven: $mvn_version"
        installed_tools=$((installed_tools + 1))
    else
        log_info "Maven: not installed"
    fi

    # Gradle (check for wrapper or global)
    if command -v gradle >/dev/null 2>&1; then
        local gradle_version
        gradle_version=$(gradle -version 2>/dev/null | grep 'Gradle' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_info "Gradle (global): $gradle_version"
        installed_tools=$((installed_tools + 1))
    else
        log_info "Gradle: Use ./gradlew (Gradle Wrapper) per project"
    fi

    log_info "Installed build tools: $installed_tools"
    log_success "Build tools status check completed"
    return 0
}

# Install Java via mise
install_java_via_mise() {
    log_info "Installing Java via mise..."

    # Parse command line options
    parse_install_options "$@"

    # Check if Java installation should be skipped
    local current_java=""
    if command -v java >/dev/null 2>&1; then
        current_java=$(java -version 2>&1 | head -1 | grep -oE '[0-9]+' | head -1 || echo "")
    fi

    local target_version="${JAVA_VERSION:-21}"

    if [[ "$FORCE_INSTALL" != "true" ]] && [[ "$current_java" == "$target_version" ]]; then
        log_skip_reason "Java $target_version" "Already installed via mise"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Java $target_version via mise"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install mise maven plugin first
        log_info "Adding mise maven plugin..."
        mise plugin install maven 2>/dev/null || true

        # Install Java (Temurin distribution - recommended LTS)
        log_info "Installing Java temurin-$target_version..."
        if mise use -g java@temurin-$target_version; then
            log_success "Java temurin-$target_version installed successfully"
        else
            log_error "Failed to install Java temurin-$target_version"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Java temurin-$target_version via mise"
    fi

    return 0
}

# Install Maven via mise
install_maven_via_mise() {
    log_info "Installing Maven via mise..."

    # Parse command line options
    parse_install_options "$@"

    # Check if Maven should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v mvn >/dev/null 2>&1; then
        log_skip_reason "Maven" "Already installed: $(mvn -version 2>/dev/null | head -1)"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Maven via mise"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Ensure maven plugin is installed
        mise plugin install maven 2>/dev/null || true

        # Install latest Maven
        log_info "Installing Maven (latest)..."
        if mise use -g maven@latest; then
            log_success "Maven installed successfully"
            if command -v mvn >/dev/null 2>&1; then
                log_info "Maven version: $(mvn -version 2>/dev/null | head -1)"
            fi
        else
            log_warning "Failed to install Maven via mise"
            log_info "Alternative: brew install maven"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Maven via mise"
    fi

    return 0
}

# Verify Java installation
verify_java_installation() {
    log_info "Verifying Java installation..."

    # Get Java path from mise
    local java_path
    java_path=$(mise where java 2>/dev/null || echo "")

    if [[ -n "$java_path" && -x "$java_path/bin/java" ]]; then
        local java_version
        java_version=$("$java_path/bin/java" -version 2>&1 | head -1)
        log_success "Java installed successfully!"
        log_info "Java version: $java_version"
        log_info "JAVA_HOME (mise): $java_path"

        # List installed versions
        log_info "Installed Java versions (mise):"
        mise list java 2>/dev/null || log_info "  No versions found"
    else
        log_error "Java installation verification failed"
        log_info "Please restart your shell and try again"
        return 1
    fi
}

# Main installation function
main() {
    log_info "Java SDK Setup via mise"
    log_info "========================"

    # Parse command line options
    parse_install_options "$@"

    # Check mise environment
    if ! check_mise_environment; then
        log_error "mise is required for Java installation"
        log_info "Install mise first: brew install mise"
        return 1
    fi

    # Check current status
    check_java_status

    # Get target Java version
    local java_version="${JAVA_VERSION:-21}"

    # Check if Java installation should be skipped entirely
    if should_skip_installation_advanced "Java" "java" "$java_version" "-version"; then
        log_info "Java is installed, checking build tools..."
        check_build_tools_status

        # Install Maven if not present
        install_maven_via_mise "$@"

        # Verify installation
        if [[ "$DRY_RUN" != "true" ]]; then
            verify_java_installation
        fi

        return 0
    fi

    # Install Java via mise
    install_java_via_mise "$@"

    # Install Maven via mise
    install_maven_via_mise "$@"

    # Check build tools status
    check_build_tools_status

    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_java_installation
    fi

    log_success "Java SDK setup completed!"
    log_info ""
    log_info "Available mise commands:"
    log_info "  mise list java              # List installed Java versions"
    log_info "  mise use java@temurin-21    # Use Java 21 (Temurin)"
    log_info "  mise use java@temurin-17    # Use Java 17 (Temurin)"
    log_info "  mise use -g java@temurin-21 # Set global default"
    log_info "  mise where java             # Show Java installation path"
    log_info ""
    log_info "For Gradle, use Gradle Wrapper (./gradlew) per project:"
    log_info "  gradle wrapper --gradle-version 8.5"
    log_info ""
    log_info "Note: Restart your shell or run 'eval \$(mise activate zsh)' to update environment"
}

# Run main function
main "$@"
