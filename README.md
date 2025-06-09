# 🏠 Dotfiles Repository

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Android-blue)](https://github.com)
[![Language](https://img.shields.io/badge/Language-日本語%20%7C%20English-green)](https://github.com)

> 🇯🇵 **Japanese Language Support**: このリポジトリは日本語環境に最適化されており、SKK日本語入力、textlint校正ルール、技術文書執筆支援を含みます。

A comprehensive, cross-platform dotfiles repository that automates development environment setup across **macOS**, **Linux**, **Windows (Cygwin)**, and **Termux (Android)**. Features modern terminal-based workflows with extensive Japanese language support.

## ✨ Features

### 🌍 **Cross-Platform Support**
- **macOS**: Homebrew, yabai/skhd tiling, Karabiner key remapping, AquaSKK
- **Linux**: i3 window manager, polybar, font installations, package management
- **Windows**: Cygwin environment with unified toolchain
- **Android**: Termux with mobile-optimized configurations

### 🛠️ **Development Environment**
- **Neovim**: 50+ plugins with LSP, completion, debugging, and AI assistance
- **Terminal**: WezTerm (primary), Alacritty, Kitty with custom themes
- **Shell**: Zsh with optimized prompt and completion systems
- **Git**: Lazygit integration and advanced Git configurations
- **Python**: Modern development with [uv](https://github.com/astral-sh/uv) package manager
- **Node.js**: [Volta](https://volta.sh/) for reliable JavaScript toolchain management
- **Flutter**: Cross-platform mobile development with FVM version management

### 🇯🇵 **Japanese Language Features**
- **SKK Input Method**: yaskkserv2 server with comprehensive dictionaries
- **Text Processing**: textlint with Japanese technical writing rules
- **Media Guidelines**: WEB+DB PRESS, TechBooster style guides
- **Trademark Validation**: Automated technical term checking

### 📝 **Knowledge Management**
- **Memolist**: Note-taking system with Nextcloud sync
- **Zettelkasten**: Knowledge management for research and documentation
- **Documentation**: Automated text linting and style checking

## 🚀 Setup Guide

### ⚠️ **Prerequisites (Required Before Installation)**

Before running any setup commands, you **MUST** configure these items locally:

#### **1. Personal Configuration** 
```bash
# Copy the template file
cp config/personal.conf.template config/personal.conf

# Edit with your information
nano config/personal.conf
```

**Required settings:**
```bash
export USER_NAME="Your Full Name"
export USER_EMAIL="your.email@example.com"
```

> ⚡ **Important**: The setup will fail without proper personal configuration!

#### **2. Git Repository URL (if needed)**
Update the clone URL to match your fork:
```bash
git clone https://github.com/YOUR-USERNAME/dotfiles.git ~/dotfiles
```

### 📦 **Installation Steps**

#### **Step 1: Clone Repository**
```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### **Step 2: Configure Personal Settings**
```bash
# Essential: Create personal configuration
cp config/personal.conf.template config/personal.conf

# Edit the file with your details
$EDITOR config/personal.conf
```

#### **Step 3: Run Complete Setup**
```bash
# Complete automated setup (recommended)
make init
```

**What `make init` does:**
- ✅ Creates symbolic links for all configuration files
- ✅ Installs platform-specific packages (Homebrew, apt, etc.)
- ✅ Sets up development tools (uv, volta, Neovim, etc.)
- ✅ Configures Git with your personal settings
- ✅ Installs fonts and terminal configurations

#### **Step 4: Verify Installation**
```bash
# Test the installation
make test

# Check status
make status
```

### 🔧 **Alternative: Step-by-Step Setup**

If you prefer manual control:

```bash
# 1. Configure Git settings
make config

# 2. Create symbolic links only
make links

# 3. Install platform-specific packages
# (varies by platform - see commands below)

# 4. Verify installation
make test
```

### 🖥️ **Platform-Specific Commands**

#### **macOS**
```bash
# Install Homebrew packages
bash bin/mac/brew.sh

# Setup fonts
bash bin/mac/fonts_setup.sh

# Configure macOS-specific settings
bash bin/mac/config.sh
```

#### **Linux**
```bash
# Install Linux packages
bash bin/linux/install_linux.sh

# Setup fonts  
bash bin/linux/apps/fonts_setup.sh

# Install Neovim
make neovim-install
```

#### **Android (Termux)**
```bash
# Complete Termux setup
make termux-setup
```

### 🔍 **Verification Commands**

```bash
# Check if dotfiles are working
make validate

# See detailed system information
make info

# Debug any issues
make debug
```

## 📋 Available Commands

Run `make help` to see all available commands:

### **Setup & Configuration**
| Command | Description |
|---------|-------------|
| `make init` | Complete dotfiles initialization |
| `make config` | Setup Git configuration |
| `make links` | Create symbolic links |
| `make termux-setup` | Android Termux environment |

### **Testing & Maintenance**
| Command | Description |
|---------|-------------|
| `make test` | Run functionality tests |
| `make status` | Show current status |
| `make validate` | Validate configuration |
| `make debug` | Troubleshooting information |
| `make clean` | Clean temporary files |
| `make backup` | Create configuration backup |

### **Specialized Tools**
| Command | Description |
|---------|-------------|
| `make memolist-config` | Setup note-taking system |
| `make zettelkasten-config` | Setup knowledge management |
| `make wezterm-install` | Build WezTerm from source |
| `make yaskkserv2-build` | Build Japanese input server |
| `make flutter-setup` | Install Flutter development environment |

## 🏗️ Architecture

### **Shared Library System**
Modern, maintainable architecture with shared libraries in `bin/lib/`:

- **`common.sh`** - Platform detection, logging, error handling
- **`config_loader.sh`** - Configuration management and version control
- **`uv_installer.sh`** - Unified Python environment setup
- **`symlink_manager.sh`** - Advanced symlink management with backup

### **Configuration Management**
- **`config/versions.conf`** - Centralized version management
- **`config/personal.conf`** - Personal settings (Git-ignored)
- **`.env.local`** - Environment variables (Git-ignored)

### **Setup Process**
1. **Platform Detection** - Automatic OS and architecture detection
2. **Configuration Loading** - Load versions and personal settings
3. **Package Installation** - Platform-specific package management
4. **Symlink Creation** - Safe linking with backup functionality
5. **Application Setup** - Install and configure development tools

## 📁 Directory Structure

```
dotfiles/
├── .config/                 # Application configurations
│   ├── nvim/               # Neovim configuration
│   ├── wezterm/            # WezTerm terminal settings
│   ├── alacritty/          # Alacritty terminal settings
│   ├── zsh/                # Zsh shell configuration
│   └── ...
├── bin/                     # Setup and utility scripts
│   ├── lib/                # Shared library system
│   │   ├── common.sh       # Core utilities
│   │   ├── config_loader.sh # Configuration management
│   │   ├── uv_installer.sh # Python environment
│   │   └── symlink_manager.sh # Link management
│   ├── mac/                # macOS-specific scripts
│   ├── linux/              # Linux-specific scripts
│   ├── termux/             # Android Termux scripts
│   └── apps/               # Application installers
├── config/                  # Configuration files
│   ├── versions.conf       # Tool version management
│   └── personal.conf.template # Personal settings template
├── textlint/               # Japanese text linting rules
└── Makefile                # Main command interface
```

## ⚙️ Configuration

### **First-Time Setup**
1. **Create Personal Configuration**:
   ```bash
   cp config/personal.conf.template config/personal.conf
   ```

2. **Edit Personal Settings**:
   ```bash
   # config/personal.conf
   export USER_NAME="Your Full Name"
   export USER_EMAIL="your.email@example.com"
   ```

3. **Validate Configuration**:
   ```bash
   make validate
   ```

### **Version Management**
Update tool versions in `config/versions.conf`:
```bash
# Example version updates
NVM_VERSION="v0.40.1"
FONT_CICA_VERSION="v5.0.3"
LAZYGIT_VERSION="0.36.0"
```

## 🐍 Python Development with uv

This repository uses [uv](https://github.com/astral-sh/uv) for fast, reliable Python package management:

### **Installation**
```bash
# uv is automatically installed via:
make init
```

### **Usage**
```bash
# Project management
uv init my-project       # Create new project
uv add requests          # Add dependency
uv run script.py         # Run script with dependencies

# Python version management
uv python install 3.12  # Install Python 3.12
uv python list           # List installed versions
```

### **Global Aliases**
Pre-configured aliases for seamless integration:
```bash
alias python='uv run python'
alias pip='uv pip'
alias pyproject-init='uv init'
```

## 📱 Flutter Development

This repository includes comprehensive Flutter development environment setup with cross-platform support.

### **Installation**
```bash
# Complete Flutter setup (recommended)
make flutter-setup

# Manual setup
bash bin/apps/flutter.sh
```

### **Features**
- **Cross-platform support**: macOS, Linux with automatic architecture detection
- **FVM integration**: Flutter Version Management for project-specific versions
- **Dependency management**: Automatic installation of platform-specific requirements
- **Development aliases**: Streamlined commands for Flutter development

### **Flutter Aliases**
```bash
# Development commands
fl doctor          # flutter doctor
flrun             # flutter run
flclean           # flutter clean
fltest            # flutter test
flpub get         # flutter pub get

# FVM commands (if installed)
fvmlist           # List available Flutter versions
fvmuse            # Switch Flutter version for project
fvminstall        # Install specific Flutter version

# Platform-specific shortcuts
ios               # Open iOS Simulator (macOS)
studio            # Open Android Studio
```

### **Configuration**
Flutter settings are managed in `config/versions.conf`:
```bash
FLUTTER_VERSION="stable"     # stable, beta, dev, or specific version
FVM_VERSION="3.1.0"         # Flutter Version Management version
DART_VERSION="stable"       # Dart SDK version
```

### **Supported Installation Methods**
- **macOS**: Homebrew (preferred) or manual installation
- **Linux**: Manual installation with automatic dependency resolution
- **Automatic detection**: Multiple Flutter installation locations supported

## 🧪 Testing

Comprehensive test suite ensures reliability across platforms:

```bash
# Run all tests
make test

# Manual validation
make status    # Check current state
make debug     # Troubleshooting info
```

**Test Coverage**:
- Platform detection and architecture identification
- Configuration loading and validation
- File operations and symlink creation
- Command availability checks
- Error handling verification

### **Continuous Integration**

This repository uses **GitHub Actions and Forgejo Actions** for automated testing:

- **🔄 Automated Testing**: Every push and pull request triggers comprehensive tests
- **🖥️ Multi-Platform**: Tests run on Ubuntu and macOS environments
- **📋 Pull Request Validation**: Ensures code quality and documentation consistency
- **🚀 Release Validation**: Comprehensive testing before releases
- **🔒 Security Checks**: Scans for potential secrets and security issues
- **🛠️ CI Environment Fixes**: Specialized handling for path resolution, Neovim AppImage installation, and uv PATH configuration

**Workflow Files**:
- `.github/workflows/test.yml` - Main test suite with PR validation
- `.github/workflows/release.yml` - Release validation and security audit

**Platform Compatibility**:
- ✅ **GitHub Actions** (github.com) - Primary CI platform
- ✅ **Forgejo Actions** (self-hosted) - Secondary/backup platform
- ✅ **Gitea Actions** (gitea.com) - Compatible workflows

**Recent CI Improvements (June 2025)**:
- Fixed Linux environment initialization failures
- Resolved Neovim download issues by switching to AppImage format
- Improved uv Python package manager PATH configuration
- Enhanced error handling for fontconfig memory issues
- Unified DOTFILES_DIR path resolution across all scripts

## 🇯🇵 Japanese Language Support

### **SKK Input Method**
- **yaskkserv2** server for high-performance input
- Comprehensive dictionaries for technical terms
- Cross-platform compatibility

### **Text Processing**
- **textlint** with Japanese grammar checking
- Technical writing style guides
- Media-specific formatting rules
- Automated proofreading workflows

### **Setup**
```bash
# Build Japanese input server
make yaskkserv2-build

# Configure text processing
# (Automatic during make init)
```

## 🛠️ Development

### **Adding New Features**
1. **Follow naming conventions**: Use `snake_case` with verb prefixes
2. **Use shared libraries**: Import from `bin/lib/` instead of duplicating
3. **Add error handling**: Use `setup_error_handling()` function
4. **Include logging**: Use `log_info()`, `log_success()`, etc.
5. **Update tests**: Add test cases for new functionality
6. **Update documentation**: Keep README and CLAUDE.md current

### **Code Quality Standards**
```bash
# Function naming
install_package()    # Installation tasks
setup_environment() # Configuration tasks
create_symlink()    # Creation tasks
detect_platform()   # Detection tasks

# Error handling
setup_error_handling
log_info "Starting process"
```

### **Contributing**
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `make test`
5. Update documentation
6. Submit a pull request

## 🔧 Troubleshooting

### **Common Issues**

**Configuration Loading Fails**:
```bash
make debug          # Check library loading
make validate       # Verify configuration
```

**Symlink Creation Errors**:
```bash
make clean          # Clean temporary files
make links          # Recreate symlinks
```

**Platform Detection Issues**:
```bash
# Manual platform check
source bin/lib/common.sh
detect_detailed_platform
```

### **Getting Help**
1. **Check status**: `make status`
2. **View debug info**: `make debug`
3. **Run tests**: `make test`
4. **Review logs**: Check error messages for specific guidance

## 📚 Documentation

- **[Library Documentation](bin/lib/README.md)** - Detailed API reference
- **[CLAUDE.md](CLAUDE.md)** - Development guidelines and architecture
- **`make help`** - Quick command reference

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[uv](https://github.com/astral-sh/uv)** - Fast Python package management
- **[Neovim](https://neovim.io/)** - Modern text editing
- **[WezTerm](https://wezfurlong.org/wezterm/)** - GPU-accelerated terminal
- **[SKK](https://github.com/skk-dev/ddskk)** - Japanese input method
- **[textlint](https://textlint.github.io/)** - Text linting framework

---

<div align="center">

**[⬆ Back to Top](#-dotfiles-repository)**

Made with ❤️ for developers who love efficient, beautiful development environments

</div>