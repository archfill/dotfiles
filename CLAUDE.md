# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Communication Language

Please conduct all interactions in Japanese (日本語) when working with this repository.

## Repository Overview

This is a comprehensive cross-platform dotfiles repository that automates development environment setup across macOS, Linux, Windows (Cygwin), and Termux (Android). It includes configurations for modern terminal-based development workflows with Japanese language support.

## Common Commands

### Main Setup Commands
- `make init` - Complete dotfiles initialization and setup
- `make termux-setup` - Setup for Android Termux environment
- `make neovim-install` - Install Neovim on Linux systems
- `make neovim-uninstall` - Remove Neovim installation

### Specialized Configuration Scripts
- `./config_memolist.sh` - Configure note-taking system with optional Nextcloud sync
- `./config_zettelkasten.sh` - Setup Zettelkasten knowledge management
- `./install_wezterm.sh` - Build and install WezTerm terminal from source
- `./make_yaskkserv2.sh` - Build Japanese SKK input method server

### Manual Setup Tasks
- `bin/init.sh` - OS detection and platform-specific setup
- `bin/link.sh` - Create symbolic links for configuration files
- `bin/apps_setup.sh` - Install applications across platforms

## Architecture and Structure

### Core Setup Process
The repository uses a multi-stage setup process:
1. **OS Detection** - `bin/init.sh` detects platform and runs appropriate setup
2. **Package Installation** - Platform-specific scripts in `bin/{mac,linux,chromebook,termux,cygwin}/`
3. **Configuration Linking** - `bin/link.sh` creates symlinks from `.config/` to home directory
4. **Application Setup** - `bin/apps_setup.sh` installs and configures applications

### Key Configuration Areas

#### Terminal and Shell
- **WezTerm**: Primary terminal with custom tab formatting and SSH-aware styling (`.config/wezterm/`)
- **Zsh**: Shell configuration with custom profile loading (`.config/zsh/`)
- **Alternative terminals**: Alacritty, Kitty configurations also provided

#### Development Environment
- **Neovim**: Extensive Lua configuration with 50+ plugins for LSP, completion, debugging (`.config/nvim/`)
- **Git**: Lazygit integration and custom Git configurations
- **Development tools**: direnv, various language version managers

#### Platform-Specific Features
- **macOS**: Homebrew packages, yabai/skhd tiling, Karabiner key remapping, AquaSKK Japanese input
- **Linux**: i3 window manager, polybar status bar, font installations
- **Japanese Support**: SKK input method, yaskkserv2 server, comprehensive text linting rules

#### Text Processing and Documentation
- **textlint**: Comprehensive proofreading setup with Japanese and technical writing rules
- **Note-taking**: Memolist and Zettelkasten systems for knowledge management

### Testing and Validation

No automated tests are present. Changes should be validated by:
1. Running setup scripts on target platforms
2. Verifying symbolic links are created correctly
3. Testing application configurations manually

### Development Workflow

When modifying configurations:
1. Edit files in `.config/` directories (not in home directory)
2. Test changes on relevant platforms
3. For new features, update appropriate platform-specific setup scripts in `bin/`
4. Consider cross-platform compatibility when adding new tools

### Japanese Language Features

This repository includes extensive Japanese language support:
- SKK input method configuration and server setup
- Textlint rules for Japanese technical writing
- Media-specific style guides (WEB+DB PRESS, TechBooster)
- Trademark and technical term validation

## Python Development with uv

This repository has migrated from pyenv to uv for Python package and project management across all platforms. uv is a fast Python package installer and resolver written in Rust.

### uv Installation

uv is automatically installed on all supported platforms:
- **macOS**: Installed via Homebrew (`bin/mac/brew.sh`)
- **Linux**: Installed via official installer script (`bin/linux/install_linux.sh`)
- **Chromebook**: Installed via official installer script (`bin/chromebook/chromebook_install.sh`)
- **Cygwin**: Installed via official installer script (`bin/cygwin/install_cygwin.sh`)
- **Termux**: Installed via dedicated setup script (`bin/apps/uv.sh`)

### uv Configuration

- **PATH Setup**: `$HOME/.cargo/bin` is added to PATH in zsh profile for all platforms
- **Shell Completion**: uv zsh completion is enabled automatically when uv is available
- **Cross-platform**: Consistent uv setup across all supported operating systems

### Python Aliases

The following aliases are configured globally to use uv instead of traditional Python tools:

```bash
alias python='uv run python'          # Run Python via uv
alias pip='uv pip'                     # Use uv pip instead of pip
alias pyproject-init='uv init'         # Initialize new Python project
alias pyenv-install='uv python install' # Install Python versions
alias pyenv-versions='uv python list'   # List installed Python versions
alias pyenv-which='uv python which'     # Show current Python path
```

### Migration from pyenv

The repository has been fully migrated from pyenv to uv:
- Removed pyenv initialization from zsh profiles (Darwin and Linux)
- Removed pyenv and pyenv-virtualenv from macOS Homebrew packages
- Replaced `bin/apps/pyenv.sh` with `bin/apps/uv.sh`
- Updated all platform-specific setup scripts to install uv instead of pyenv

### uv Usage

- **Project Management**: Use `uv init` to create new Python projects with pyproject.toml
- **Python Versions**: Use `uv python install 3.12` to install specific Python versions
- **Package Installation**: Use `uv add <package>` or `uv pip install <package>`
- **Virtual Environments**: uv automatically manages virtual environments per project
- **Running Scripts**: Use `uv run <script.py>` to run Python scripts with proper dependencies