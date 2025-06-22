#!/usr/bin/env bash

# Terraform installation script using tfenv
# This script installs tfenv and manages Terraform versions

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Terraform setup via tfenv..."

# Get Terraform version with automatic detection
get_terraform_version() {
  # Check versions.conf setting
  if [[ "${TERRAFORM_VERSION:-}" == "latest" ]]; then
    # Try to get latest version from HashiCorp API
    local latest_version
    latest_version=$(curl -s --connect-timeout 10 "https://api.releases.hashicorp.com/v1/releases/terraform" 2>/dev/null | \
      grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null)
    
    if [[ -n "$latest_version" ]]; then
      echo "$latest_version"
    else
      # Fallback to known stable version
      echo "1.6.6"
    fi
  else
    # Use explicitly specified version
    echo "${TERRAFORM_VERSION:-1.6.6}"
  fi
}

# Install tfenv
install_tfenv() {
  log_info "Installing tfenv..."
  
  # Check if tfenv is already installed
  if command -v tfenv >/dev/null 2>&1; then
    log_success "tfenv is already installed: $(tfenv --version 2>/dev/null || echo 'version unknown')"
    return 0
  fi
  
  # Install tfenv via git
  local tfenv_dir="$HOME/.tfenv"
  
  if [[ -d "$tfenv_dir" ]]; then
    log_info "tfenv directory exists, updating..."
    cd "$tfenv_dir" && git pull
  else
    log_info "Cloning tfenv..."
    git clone --depth 1 https://github.com/tfutils/tfenv.git "$tfenv_dir"
  fi
  
  # Add tfenv to PATH for current session
  export PATH="$tfenv_dir/bin:$PATH"
  
  if command -v tfenv >/dev/null 2>&1; then
    log_success "tfenv installed successfully"
  else
    log_error "tfenv installation failed"
    exit 1
  fi
}

# Install specified Terraform version
install_terraform_version() {
  local terraform_version="$1"
  
  log_info "Installing Terraform $terraform_version via tfenv..."
  
  # Ensure tfenv is available
  if ! command -v tfenv >/dev/null 2>&1; then
    export PATH="$HOME/.tfenv/bin:$PATH"
  fi
  
  # Check if this version is already installed
  if tfenv list | grep -q "$terraform_version"; then
    log_success "Terraform $terraform_version is already installed"
    tfenv use "$terraform_version"
    return 0
  fi
  
  # Install Terraform version
  log_info "This may take a few minutes..."
  if tfenv install "$terraform_version"; then
    log_success "Terraform $terraform_version installed successfully"
    
    # Set as current version
    tfenv use "$terraform_version"
  else
    log_error "Terraform $terraform_version installation failed"
    exit 1
  fi
}

# Install Terraform autocompletion
setup_terraform_completion() {
  log_info "Setting up Terraform autocompletion..."
  
  # Ensure terraform is available
  if ! command -v terraform >/dev/null 2>&1; then
    log_warning "Terraform not found in PATH, skipping autocompletion setup"
    return 1
  fi
  
  # Install autocompletion for current user
  terraform -install-autocomplete >/dev/null 2>&1 || log_info "Autocompletion already installed or setup failed"
  
  log_success "Terraform autocompletion setup completed"
}

# Install useful Terraform tools
install_terraform_tools() {
  log_info "Installing useful Terraform tools..."
  
  # List of useful tools
  local tools_info=(
    "tflint:github.com/terraform-linters/tflint:Terraform linter"
    "terraform-docs:github.com/terraform-docs/terraform-docs:Documentation generator"
    "terragrunt:github.com/gruntwork-io/terragrunt:Terraform wrapper"
    "tfsec:github.com/aquasecurity/tfsec:Security scanner"
  )
  
  for tool_info in "${tools_info[@]}"; do
    local tool_name=$(echo "$tool_info" | cut -d: -f1)
    local tool_source=$(echo "$tool_info" | cut -d: -f2)
    local tool_desc=$(echo "$tool_info" | cut -d: -f3)
    
    if ! command -v "$tool_name" >/dev/null 2>&1; then
      log_info "Installing $tool_name ($tool_desc)..."
      
      case "$tool_source" in
        github.com/*)
          # Install via go install if available
          if command -v go >/dev/null 2>&1; then
            go install "$tool_source@latest" || log_warning "Failed to install $tool_name"
          else
            log_warning "Go not available, skipping $tool_name"
          fi
          ;;
        *)
          log_warning "Unknown installation method for $tool_name"
          ;;
      esac
    else
      log_info "$tool_name is already installed"
    fi
  done
  
  log_success "Terraform tools installation completed"
}

# Setup Terraform environment
setup_terraform_environment() {
  log_info "Setting up Terraform environment..."
  
  # Add tfenv to PATH
  if ! command -v tfenv >/dev/null 2>&1; then
    export PATH="$HOME/.tfenv/bin:$PATH"
  fi
  
  # Set environment variables
  export TF_CLI_CONFIG_FILE="${TF_CLI_CONFIG_FILE:-$HOME/.terraformrc}"
  export TFENV_ROOT="${TFENV_ROOT:-$HOME/.tfenv}"
  
  log_info "TFENV_ROOT: $TFENV_ROOT"
  
  if command -v terraform >/dev/null 2>&1; then
    log_info "Terraform location: $(which terraform)"
    log_info "Active Terraform version: $(terraform --version | head -1)"
  fi
}

# Verify Terraform installation
verify_terraform_installation() {
  log_info "Verifying Terraform installation..."
  
  # Setup environment if needed
  setup_terraform_environment
  
  if command -v terraform >/dev/null 2>&1 && command -v tfenv >/dev/null 2>&1; then
    log_success "Terraform and tfenv installed successfully!"
    
    # Show tfenv info
    log_info "tfenv version: $(tfenv --version 2>/dev/null || echo 'version info not available')"
    log_info "Installed Terraform versions:"
    tfenv list
    
    # Show current version
    local current_version=$(terraform --version | head -1)
    log_info "Active version: $current_version"
    
    # Test basic Terraform functionality
    log_info "Testing Terraform installation..."
    if terraform --help >/dev/null 2>&1; then
      log_success "Terraform installation test passed"
    else
      log_warning "Terraform installation test failed"
    fi
    
    # Check for autocompletion
    if [[ -f "$HOME/.bashrc" ]] && grep -q "terraform" "$HOME/.bashrc"; then
      log_info "Autocompletion is enabled"
    elif [[ -f "$HOME/.zshrc" ]] && grep -q "terraform" "$HOME/.zshrc"; then
      log_info "Autocompletion is enabled"
    fi
  else
    log_error "Terraform or tfenv installation verification failed"
    log_info "Please restart your shell and try again"
    exit 1
  fi
}

# Setup Terraform development environment
setup_terraform_development() {
  log_info "Setting up Terraform development environment..."
  
  # Create .terraform-version file for project-level version management
  local test_dir="$HOME/tmp/terraform-test"
  if [[ ! -d "$test_dir" ]]; then
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Create sample Terraform configuration
    cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "test" {
  content  = "Terraform with tfenv is working!"
  filename = "test.txt"
}
EOF
    
    # Create .terraform-version file
    if command -v terraform >/dev/null 2>&1; then
      terraform --version | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/v//' > .terraform-version
      
      terraform init >/dev/null 2>&1
      if [[ -f ".terraform.lock.hcl" ]]; then
        log_success "Terraform development environment working correctly"
        rm -rf "$test_dir"
      fi
    fi
  fi
}

# Install multiple Terraform versions (useful for compatibility testing)
install_terraform_versions() {
  log_info "Installing common Terraform versions..."
  
  # Ensure tfenv is available
  if ! command -v tfenv >/dev/null 2>&1; then
    export PATH="$HOME/.tfenv/bin:$PATH"
  fi
  
  # List of commonly used Terraform versions
  local common_versions=(
    "1.6.6"    # Latest stable
    "1.5.7"    # Previous stable
    "1.4.7"    # LTS-like version
  )
  
  for version in "${common_versions[@]}"; do
    if ! tfenv list | grep -q "$version"; then
      log_info "Installing Terraform $version..."
      tfenv install "$version" || log_warning "Failed to install Terraform $version"
    else
      log_info "Terraform $version is already installed"
    fi
  done
  
  log_success "Common Terraform versions installation completed"
}

# Main installation function
main() {
  log_info "Terraform Setup via tfenv"
  log_info "=========================="
  
  # Check if Terraform is already managed by tfenv
  if command -v tfenv >/dev/null 2>&1 && command -v terraform >/dev/null 2>&1; then
    local current_version=$(terraform --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
    log_success "Terraform is already managed by tfenv: $current_version"
    
    # Setup environment and verify
    setup_terraform_environment
    setup_terraform_completion
    install_terraform_tools
    setup_terraform_development
    verify_terraform_installation
    return 0
  fi
  
  # Get target Terraform version
  local terraform_version
  terraform_version=$(get_terraform_version)
  
  log_info "Determining Terraform version..."
  if [[ "${TERRAFORM_VERSION:-}" == "latest" ]]; then
    log_info "Latest version requested, resolved to: $terraform_version"
  else
    log_info "Using specified Terraform version: $terraform_version"
  fi
  
  # Install tfenv
  install_tfenv
  
  # Install target Terraform version
  install_terraform_version "$terraform_version"
  
  # Setup environment
  setup_terraform_environment
  
  # Setup autocompletion
  setup_terraform_completion
  
  # Install useful tools
  install_terraform_tools
  
  # Install common versions for compatibility testing
  install_terraform_versions
  
  # Setup development environment
  setup_terraform_development
  
  # Verify installation
  verify_terraform_installation
  
  log_success "Terraform setup via tfenv completed!"
  log_info ""
  log_info "Available tfenv commands:"
  log_info "  tfenv list              # List installed Terraform versions"
  log_info "  tfenv list-remote       # List available versions"
  log_info "  tfenv install <version> # Install specific Terraform version"
  log_info "  tfenv use <version>     # Switch to specific version"
  log_info "  tfenv uninstall <ver>   # Uninstall specific version"
  log_info ""
  log_info "Available Terraform commands:"
  log_info "  terraform --version     # Show current Terraform version"
  log_info "  terraform init          # Initialize working directory"
  log_info "  terraform plan          # Create execution plan"
  log_info "  terraform apply         # Apply changes"
  log_info "  terraform destroy       # Destroy infrastructure"
  log_info "  terraform validate      # Validate configuration"
  log_info "  terraform fmt           # Format configuration files"
  log_info ""
  log_info "Project-level version management:"
  log_info "  Create .terraform-version file in your project"
  log_info "  tfenv will automatically use the specified version"
  log_info ""
  log_info "Useful tools (if installed):"
  log_info "  tflint                  # Terraform linter"
  log_info "  terraform-docs          # Generate documentation"
  log_info "  terragrunt              # Terraform wrapper for DRY configurations"
  log_info "  tfsec                   # Security scanner"
  log_info ""
  log_info "Environment setup:"
  log_info "  Add to your shell profile (~/.zshrc or ~/.bashrc):"
  log_info "    export PATH=\"\$HOME/.tfenv/bin:\$PATH\""
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"