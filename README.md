# 🏠 Dotfiles Repository

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Android-blue)](https://github.com)

Cross-platform dotfiles for modern development environments with Japanese language support.

## ✨ Features

- **Multi-Platform**: macOS, Linux, Windows (Cygwin), Android (Termux)
- **Modern Tools**: Neovim, WezTerm, Zsh with optimized configurations
- **Japanese Support**: SKK input method, textlint for technical writing
- **Development Ready**: Python (uv), Node.js (volta), Flutter, Docker support

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Configure personal settings
cp config/personal.conf.template config/personal.conf
$EDITOR config/personal.conf  # Set USER_NAME and USER_EMAIL

# Complete setup
make init
```

### 2. Essential Commands

```bash
make init     # Complete installation
make test     # Verify setup
make status   # Check status
make help     # Show all commands
```

## 📁 Key Configurations

- **Neovim**: `.config/nvim/` - 50+ plugins with LSP support
- **Zsh**: `.config/zsh/` - Optimized shell with completions
- **Terminal**: `.config/wezterm/` - Modern terminal configuration
- **Git**: Global git settings and lazygit/gitu TUI integration

## 🌍 Platform Support

| Platform | Package Manager | Window Manager |
|----------|----------------|----------------|
| macOS    | Homebrew       | yabai/skhd     |
| Linux    | apt/pacman/dnf | i3/polybar     |
| Windows  | Cygwin         | Native         |
| Android  | Termux         | Native         |

## 🇯🇵 Japanese Features

- **SKK Input**: yaskkserv2 server with comprehensive dictionaries
- **Text Linting**: textlint for technical Japanese writing
- **Media Styles**: WEB+DB PRESS, TechBooster style guides

## 🛠️ Development Tools

### Programming Languages
- **Python**: uv package manager (modern pyenv replacement)
- **Node.js**: volta toolchain manager (replaces nvm/fnm)
- **Rust**: rustup with essential tools (clippy, rustfmt)
- **Go**: g version manager with development tools
- **Java**: SDKMAN! for JDK management

### Development Environment
- **Editor**: Neovim with LSP, completion, and debugging
- **Terminal**: WezTerm with custom themes and SSH integration
- **Git**: Advanced configurations with lazygit/gitu TUI interface
- **Containers**: Docker and Docker Compose setup
- **Mobile**: Flutter with FVM version management

## 📖 Documentation

For detailed setup instructions and troubleshooting:
- [日本語ドキュメント](README.ja.md)
- [CLAUDE.md](CLAUDE.md) - AI assistant guidance
- [Makefile](Makefile) - Available commands

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test changes with `make test`
4. Update documentation if needed
5. Submit a pull request

## 📄 License

[MIT License](LICENSE) - Feel free to use and modify for your own dotfiles setup.