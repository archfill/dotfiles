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

### 🇯🇵 **Japanese Language Features**
- **SKK Input Method**: yaskkserv2 server with comprehensive dictionaries
- **Text Processing**: textlint with Japanese technical writing rules
- **Media Guidelines**: WEB+DB PRESS, TechBooster style guides
- **Trademark Validation**: Automated technical term checking

### 📝 **Knowledge Management**
- **Memolist**: Note-taking system with Nextcloud sync
- **Zettelkasten**: Knowledge management for research and documentation
- **Documentation**: Automated text linting and style checking

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Initial Setup
```bash
# Complete setup (recommended)
make init

# Or step-by-step setup
make config    # Configure Git settings
make links     # Create symbolic links
make test      # Verify installation
```

### 3. Platform-Specific Setup
```bash
# For Android Termux
make termux-setup

# For Linux Neovim installation
make neovim-install
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

This repository uses **Forgejo Actions** for automated testing:

- **🔄 Automated Testing**: Every push and pull request triggers comprehensive tests
- **🖥️ Multi-Platform**: Tests run on Ubuntu and macOS environments
- **📋 Pull Request Validation**: Ensures code quality and documentation consistency
- **🚀 Release Validation**: Comprehensive testing before releases
- **🔒 Security Checks**: Scans for potential secrets and security issues

**Workflow Files**:
- `.github/workflows/test.yml` - Main test suite with PR validation
- `.github/workflows/release.yml` - Release validation and security audit

**Platform Compatibility**:
- ✅ **GitHub Actions** (github.com)
- ✅ **Forgejo Actions** (self-hosted)
- ✅ **Gitea Actions** (gitea.com)

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