# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Communication Language

Please conduct all interactions in Japanese (日本語) when working with this repository.

## Repository Overview

This is a comprehensive cross-platform dotfiles repository that automates development environment setup across macOS, Linux, Windows (Cygwin), and Termux (Android). It includes configurations for modern terminal-based development workflows with Japanese language support.

## Common Commands

### Main Setup Commands
- `make init` - Complete dotfiles initialization and setup
- `make config` - Setup Git configuration with personal settings
- `make links` - Create symbolic links for dotfiles
- `make termux-setup` - Setup for Android Termux environment
- `make neovim-install` - Install Neovim on Linux systems
- `make neovim-uninstall` - Remove Neovim installation

### Testing and Maintenance Commands
- `make test` - Run dotfiles functionality tests
- `make status` - Show current dotfiles status and configuration
- `make info` - Display system and dotfiles information
- `make validate` - Validate dotfiles configuration and structure
- `make debug` - Show debug information for troubleshooting
- `make clean` - Clean up temporary files and caches
- `make update` - Update dotfiles and submodules
- `make backup` - Create backup of current configuration
- `make help` - Show all available commands with descriptions

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
2. **Configuration Loading** - Shared configuration system loads versions and personal settings
3. **Package Installation** - Platform-specific scripts in `bin/{mac,linux,chromebook,termux,cygwin}/`
4. **Configuration Linking** - `bin/link.sh` creates symlinks from `.config/` to home directory
5. **Application Setup** - `bin/apps_setup.sh` installs and configures applications

### Shared Library System

The repository now includes a comprehensive shared library system in `bin/lib/`:

#### Core Libraries
- **`common.sh`** - Platform detection, logging, error handling, utility functions
- **`config_loader.sh`** - Configuration management, version control, personal settings
- **`uv_installer.sh`** - Unified Python environment management with uv
- **`symlink_manager.sh`** - Advanced symlink creation with backup and validation

#### Configuration Management
- **`config/versions.conf`** - Centralized version management for all tools
- **`config/personal.conf`** - Personal settings (Git excluded, created from template)
- **`.env.local`** - Environment variables (Git excluded)

#### Benefits
- **Eliminates code duplication** across platform-specific scripts
- **Provides consistent error handling** and logging across all scripts
- **Enables centralized configuration management** for easier maintenance
- **Supports platform-specific customization** while maintaining shared functionality

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

Automated testing is now available via the test suite. Changes should be validated by:
1. Running `make test` to execute the automated test suite
2. Running setup scripts on target platforms
3. Verifying symbolic links are created correctly
4. Testing application configurations manually

#### Test Suite
- **Test Script**: `bin/test.sh` provides comprehensive functionality testing
- **Test Coverage**: Platform detection, configuration loading, file operations, command checks
- **Usage**: `make test` or `bash bin/test.sh`

### Development Workflow

When modifying configurations:
1. Edit files in `.config/` directories (not in home directory)
2. Test changes using `make test` for basic validation
3. Test changes on relevant platforms
4. For new features, update appropriate platform-specific setup scripts in `bin/`
5. Consider cross-platform compatibility when adding new tools
6. **Update documentation and tests when adding new functionality**
7. **IMPORTANT: Update README.md and README.ja.md after any significant changes or new features**

#### Code Quality Standards
- Follow snake_case naming convention for files and functions
- Use verb prefixes for functions (install_, setup_, create_, detect_, etc.)
- Include proper error handling with `setup_error_handling()`
- Use shared libraries from `bin/lib/` instead of duplicating code
- Add appropriate logging with `log_info()`, `log_success()`, etc.

#### Documentation Requirements
- **README Updates**: Any changes to commands, features, or architecture must be reflected in both README.md and README.ja.md
- **Version Consistency**: Ensure both language versions contain equivalent information
- **Command Updates**: When adding new make targets or scripts, update the command tables in both READMEs
- **Architecture Changes**: Document any modifications to the shared library system or configuration management

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

## Recent Major Refactoring (2025年6月)

A comprehensive refactoring was performed to modernize the codebase and improve maintainability:

### Phase 1: Emergency Fixes (緊急修正)
- **Created shared library system** in `bin/lib/` with common functions
- **Unified uv installation** across all platforms using `bin/lib/uv_installer.sh`
- **Fixed syntax errors** in `install_wezterm.sh` (corrected backtick usage and error handling)
- **Standardized error handling** with `setup_error_handling()` function
- **Updated 5 scripts** to use shared libraries: Linux, Cygwin, Chromebook installers, and uv app script

### Phase 2: Structural Improvements (構造改善)
- **Externalized configuration**: Created `config/versions.conf` for version management
- **Removed hardcoded personal information**: Moved Git user settings to external configuration
- **Unified platform detection**: Enhanced `bin/lib/common.sh` with comprehensive platform detection
- **Created configuration loader**: `bin/lib/config_loader.sh` for centralized settings management
- **Unified symlink management**: `bin/lib/symlink_manager.sh` with backup functionality
- **Updated .gitignore**: Added exclusions for personal configuration files

### Phase 3: Quality Improvements (品質向上)
- **Standardized naming conventions**: Converted to snake_case with verb prefixes
- **Enhanced documentation**: Created comprehensive `bin/lib/README.md`
- **Added test suite**: `bin/test.sh` with 8 automated tests
- **Expanded Makefile**: Added 20+ new commands with help system
- **Modernized existing scripts**: Updated Neovim installer with shared libraries

### Benefits Achieved
- **Eliminated code duplication**: 4 uvinstall scripts → 1 shared function
- **Improved security**: Personal information no longer hardcoded
- **Enhanced reliability**: Unified error handling and logging
- **Better maintainability**: Centralized configuration management
- **Increased testability**: Automated test suite for core functionality
- **Improved user experience**: Rich command-line interface with `make help`

### Files Created/Modified in Refactoring
#### New Files:
- `bin/lib/common.sh` - Core utilities and platform detection
- `bin/lib/config_loader.sh` - Configuration management system
- `bin/lib/uv_installer.sh` - Unified Python environment setup
- `bin/lib/symlink_manager.sh` - Advanced symlink management
- `bin/lib/README.md` - Comprehensive library documentation
- `bin/test.sh` - Automated test suite
- `config/versions.conf` - Centralized version management
- `config/personal.conf.template` - Personal settings template

#### Modified Files:
- `bin/config.sh` - Externalized personal information
- `bin/link.sh` - Modernized with shared libraries
- `bin/linux/install_linux.sh` - Uses shared uv installer
- `bin/cygwin/install_cygwin.sh` - Uses shared libraries
- `bin/chromebook/chromebook_install.sh` - Uses shared libraries
- `bin/apps/uv.sh` - Unified installation approach
- `bin/linux/apps/neovim_install.sh` - Complete modernization
- `install_wezterm.sh` - Fixed syntax and added proper error handling
- `Makefile` - Extensive expansion with 20+ new commands
- `.gitignore` - Added personal configuration exclusions
- `.config/alacritty/alacritty_chromebook.yml` - Renamed for consistency

This refactoring transforms the repository from a collection of individual scripts into a cohesive, maintainable system with proper software engineering practices.

#### Documentation Updates (2025年6月)
- **Created comprehensive README.md**: English documentation with full feature coverage
- **Created README.ja.md**: Japanese localized documentation with cultural considerations
- **Updated CLAUDE.md**: Added refactoring history and development guidelines
- **Added library documentation**: bin/lib/README.md with detailed API reference

#### CI/CD Implementation (2025年6月)
- **Created unified GitHub Actions workflows**: Compatible with GitHub, Forgejo, and Gitea
- **Main test suite**: `.github/workflows/test.yml` with multi-platform testing and PR validation
- **Release validation**: `.github/workflows/release.yml` with comprehensive release testing and security audit
- **Cross-platform compatibility**: Works seamlessly across GitHub Actions, Forgejo Actions, and Gitea Actions
- **Security scanning**: Automated checks for potential secrets and security issues
- **Intelligent platform detection**: Automatically adapts behavior based on the hosting platform

## Documentation Maintenance Rules

### CRITICAL REQUIREMENT: README Synchronization
**Any modifications to this repository MUST include corresponding updates to the README files.**

#### When to Update READMEs:
1. **New commands added** to Makefile
2. **New scripts or libraries** created in bin/
3. **Configuration changes** that affect user workflow
4. **Architecture modifications** in the shared library system
5. **New platform support** or feature additions
6. **Version updates** in config/versions.conf
7. **Any breaking changes** that affect existing functionality

#### Update Process:
1. Modify functionality/add features
2. Test changes with `make test`
3. Update README.md (English)
4. Update README.ja.md (Japanese) with equivalent content
5. Verify both versions are consistent
6. Commit all changes together

#### Documentation Standards:
- **Accuracy**: All commands and examples must work as documented
- **Completeness**: Both language versions must contain equivalent information
- **Clarity**: Use clear, concise language appropriate for each audience
- **Examples**: Include practical, copy-pasteable examples
- **Structure**: Maintain consistent section organization across versions

This ensures users always have access to current, accurate documentation regardless of their language preference.

## Work History and Issue Resolution (作業履歴と問題解決)

### 2025年6月 - 主要な作業記録

#### GitHub Actions CI/CD修正 (2025年6月9日)
**問題**: GitHub ActionsワークフローでLinux環境の初期化が複数のエラーで失敗  
**修正内容**:  
1. **パス参照エラー**: `bin/linux/install_linux.sh`で`get_os_info.sh`のパスを`$HOME/dotfiles`から`$DOTFILES_DIR`に修正
2. **Neovimダウンロード失敗**: tar.gz形式からAppImage形式に変更（404エラー解決）
   - 旧URL: `nvim-linux64.tar.gz` → 新URL: `nvim-linux-x86_64.appimage`
   - `~/.local/bin`に直接実行可能ファイルとしてインストール
3. **uvインストールPATH問題**: `~/.local/bin`パスの追加とインストール検証の改善
4. **appsセットアップパスエラー**: `bin/apps_setup.sh`で固定パスを`$DOTFILES_DIR`に変更
5. **fontconfigメモリエラー**: CI環境でのメモリエラーを警告レベルに変更

**結果**: GitHub ActionsでのLinux環境初期化が完全に動作するようになった

#### Git管理の問題解決
**問題**: `bin/lib/` ディレクトリがGit管理対象外になっている  
**原因**: `.gitignore`の79行目にある`lib/`パターンが、Python関連のlibディレクトリを除外する際に`bin/lib/`も除外していた  
**解決**: 80行目に`!bin/lib/`を追加し、bin/lib/ディレクトリを明示的に管理対象に含める  
**影響**: 共有ライブラリシステムが正常にバージョン管理されるようになった

#### Git設定の更新
**変更**: Gitのユーザー名を「Yusaku Hieda」から「archfill」に変更  
**コマンド**: `git config --global user.name "archfill"`  
**確認**: `git config --global user.name`で変更を確認済み

#### リポジトリ構成の確認
- **Origin remote**: Forgejoサーバー（メインリポジトリ）
- **GitHub remote**: GitHubリポジトリ（ミラーまたはバックアップ）
- 両方のプラットフォームで GitHub Actions/Forgejo Actions 互換のワークフローが動作

#### 成果物の確認
- **bin/lib/共有ライブラリシステム**: 正常にGit管理対象
- **CI/CDワークフロー**: GitHub, Forgejo, Gitea互換で動作確認済み
- **ドキュメント**: README.md（英語）、README.ja.md（日本語）両方完備
- **テストスイート**: `bin/test.sh`による包括的テスト
- **設定管理**: `config/versions.conf`による一元化

#### 技術的決定と教訓
1. **.gitignoreの設計**: 包括的除外パターンを使用する際は、必要なディレクトリの明示的包含（`!pattern`）を忘れずに追加
2. **Git設定管理**: グローバル設定変更は影響範囲が広いため、変更前後の確認を必須とする
3. **ドキュメント保守**: 作業内容は必ずCLAUDE.mdに記録し、後の参照と学習に活用
4. **リポジトリ構成**: 複数のGitサービス（Forgejo + GitHub）を使用する場合の運用方法確立

### トラブルシューティング指針

#### bin/lib/がGit管理対象外になった場合
```bash
# 問題確認
git status | grep "bin/lib"

# .gitignoreの確認
grep -n "lib/" .gitignore

# 解決方法: .gitignoreに例外パターンを追加
echo "!bin/lib/" >> .gitignore
git add .gitignore bin/lib/
git commit -m "Fix: Include bin/lib/ in Git tracking"
```

#### Git設定の確認・変更
```bash
# 現在の設定確認
git config --global user.name
git config --global user.email

# 設定変更
git config --global user.name "新しい名前"
git config --global user.email "新しいメール"
```

#### CI/CDトラブルシューティング
```bash
# ワークフローファイルの構文チェック
yamllint .github/workflows/*.yml

# テストの本地実行
make test
bash bin/test.sh
```

#### GitHub Actions固有の問題解決
```bash
# Neovimインストール問題の確認
curl -I https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage

# uvインストール後のPATH確認
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
which uv

# パス参照問題の確認
echo "DOTFILES_DIR: $DOTFILES_DIR"
ls -la "${DOTFILES_DIR}/bin/get_os_info.sh"
```

### GitHub Actions修正履歴
- **2025年6月9日**: 完全なCI環境修正
  - パス参照問題、Neovimダウンロード、uvインストール、appsセットアップの4つの主要問題を解決
  - Linux環境での初期化プロセスが100%成功するように修正
  - fontconfigエラーの適切な処理を追加