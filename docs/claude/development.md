# Development Environment Guide for Claude Code

このドキュメントは開発環境のセットアップと技術統合に関する詳細情報をまとめています。

## 目次

- [Python Development with uv](#python-development-with-uv)
- [Node.js Management with mise](#nodejs-management-with-mise)
- [Flutter Development](#flutter-development)
- [Shared Library System](#shared-library-system)
- [Code Quality Standards](#code-quality-standards)

---

## Python Development with uv

### Migration Complete (2025年6月)

- **Migration**: Fully migrated from pyenv to uv for Python management
- **Installation**: Automatic installation across all platforms
- **Aliases**: Global aliases for `python`, `pip`, `pyproject-init`, etc.
- **Usage**: `uv init` for projects, `uv python install X.Y` for versions

### Key Commands

```bash
# Install Python version
uv python install 3.12

# Create new project
uv init my-project

# Manage dependencies
uv add package-name
uv sync
```

---

## Node.js Management with mise

### Unified Solution (2025年12月)

- **Unified Solution**: Migrated from volta to mise (polyglot version manager)
- **Cross-platform**: Consistent setup across macOS, Linux, WSL
- **Project Support**: Automatic version switching per project via `.mise.toml` or `.tool-versions`
- **Multi-language**: mise also manages Python, Ruby, Go, and other runtimes

### Key Commands

```bash
# Install Node.js version
mise use -g node@lts

# Pin version for project
mise use node@20

# Install global packages
npm install -g typescript
```

---

## Flutter Development

### Complete Integration (2025年6月)

- **SDK Management**: FVM is provided by Nix/Home Manager
- **Version Management**: Flutter SDK versions are selected per project with FVM
- **Environment**: Dynamic path detection and Flutter environment setup

### FVM Usage

```bash
# Install Flutter version
fvm install stable

# Use specific version
fvm use 3.10.0

# Global version
fvm global stable
```

---

## Shared Library System

The repository includes a comprehensive shared library system in `bin/lib/`:

### Core Libraries

- **`common.sh`** - Platform detection, logging, error handling, utility functions
- **`config_loader.sh`** - Configuration management, version control, personal settings
- **`uv_installer.sh`** - Unified Python environment management with uv
- **`symlink_manager.sh`** - Advanced symlink creation with backup and validation

### Configuration Management

- **`config/versions.conf`** - Centralized version management for all tools
- **`config/personal.conf`** - Personal settings (Git excluded, created from template)
- **`.env.local`** - Environment variables (Git excluded)

### Usage Example

```bash
# In any script
source "$DOTFILES/bin/lib/common.sh"
source "$DOTFILES/bin/lib/config_loader.sh"

# Use functions
log_info "Installing packages..."
load_config_file "$CONFIG_DIR/versions.conf"
```

---

## Code Quality Standards

### Naming Conventions

- Use snake_case for files and functions
- Use verb prefixes for functions (install*, setup*, create*, detect*, etc.)
- Follow consistent patterns across platforms

### Error Handling

- Include proper error handling with `setup_error_handling()`
- Use shared logging functions from `bin/lib/common.sh`
- Provide meaningful error messages

### Testing

- Run `make test` before committing changes
- Test on target platforms when possible
- Verify symbolic links are created correctly

### Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source shared libraries
source "$DOTFILES/bin/lib/common.sh"
source "$DOTFILES/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Main logic
main() {
    log_info "Starting setup..."

    # Your code here

    log_success "Setup completed!"
}

# Run main function
main "$@"
```

---

## Important Technical Decisions

### 2025年6月 Major Refactoring Summary

- **Shared Library System**: Created `bin/lib/` to eliminate code duplication
- **Configuration Externalization**: Moved versions and personal settings to `config/`
- **Python Migration**: Fully migrated from pyenv to uv across all platforms
- **Node.js Unification**: Standardized on mise for all Node.js version management (migrated from volta in 2025年12月)
- **CI/CD Implementation**: Created unified workflows for GitHub/Forgejo/Gitea compatibility

### Key Lessons Learned

1. **Centralized Configuration**: External configuration files improve maintainability
2. **Shared Libraries**: Eliminate duplication and improve consistency
3. **Platform Detection**: Dynamic path detection improves cross-platform compatibility
4. **Modern Toolchains**: Regular migration to actively maintained tools prevents technical debt
5. **Documentation Sync**: Consistent bilingual documentation is critical for usability
