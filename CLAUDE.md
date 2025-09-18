# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📚 Detailed Documentation

For detailed information on specific topics, see:
- **[Neovim Configuration](docs/claude/neovim.md)** - Neovim設定、プラグイン管理、パフォーマンス最適化
- **[Development Environment](docs/claude/development.md)** - Python/uv、Node.js/volta、Flutter開発環境
- **[Policies and Rules](docs/claude/policies.md)** - シェル環境設定ポリシー、ドキュメント要件
- **[Historical Records](docs/claude/archives/history.md)** - 過去の調査記録、解決済み問題

## 🛠️ Available MCP Tools for Latest Information

**ALWAYS USE THESE TOOLS** for up-to-date information instead of relying on training data:

### Context7 Library Documentation
- **Tool**: `mcp__Context7__resolve-library-id` and `mcp__Context7__get-library-docs`
- **Purpose**: Get current documentation for libraries and frameworks
- **Example**: Use for Neovim plugins, JavaScript frameworks, Python libraries

### DeepWiki Repository Information
- **Tool**: `mcp__mcp-deepwiki__deepwiki_fetch`
- **Purpose**: Fetch latest repository information and documentation
- **Example**: Use for GitHub repositories, project documentation, README files

### Web Search for Current Information
- **Tool**: `mcp__ddg-search__search` and `mcp__ddg-search__fetch_content`
- **Purpose**: Search for latest information and fetch webpage content
- **Example**: Use for latest plugin releases, API changes, compatibility issues

## 🌍 Communication Language

Please conduct all interactions in **Japanese (日本語)** when working with this repository.

## 📋 Repository Overview

This is a comprehensive **cross-platform dotfiles repository** that automates development environment setup across macOS, Linux, Windows (Cygwin), and Termux (Android). It includes configurations for modern terminal-based development workflows with Japanese language support.

## ⚡ Essential Commands

### Core Setup
- `make init` - Complete dotfiles initialization and setup
- `make test` - Run comprehensive functionality tests
- `make config` - Setup Git configuration with personal settings
- `make links` - Create symbolic links for dotfiles
- `make help` - Show all available commands

### Platform-Specific
- `make termux-setup` - Android Termux environment
- `make neovim-install` - Install Neovim on Linux
- `make flutter-setup` - Setup Flutter development

### Maintenance
- `make status` - Current dotfiles status
- `make update` - Update dotfiles and submodules
- `make clean` - Clean temporary files and caches
- `make backup` - Backup current configuration

⚠️ **For detailed documentation on specific topics, see the linked documents above.**
