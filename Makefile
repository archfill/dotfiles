# Dotfiles Management Makefile
# 
# このMakefileは、dotfilesの各種操作を簡単に実行するためのコマンドを提供します。
# 使用方法: make <target>
# ヘルプ: make help

.PHONY: all help init config links test clean status info fonts fonts-list fonts-install flutter-setup neovim-setup neovim-stable neovim-nightly neovim-status neovim-install neovim-uninstall neovim-toggle neovim-update nvim-s nvim-n nvim-t nvim-u
.DEFAULT_GOAL := help

# デフォルトターゲット
all: init

# ヘルプ表示
help: ## Show this help message
	@echo "Dotfiles Management Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make init          # Complete dotfiles setup"
	@echo "  make test          # Run all tests"
	@echo "  make links         # Create symlinks only"
	@echo "  make config        # Setup Git configuration"

# 基本セットアップ
init: ## Complete dotfiles initialization and setup
	@echo "Starting complete dotfiles initialization..."
	bash ./bin/init.sh

config: ## Setup Git configuration with personal settings
	@echo "Setting up Git configuration..."
	bash ./bin/config.sh

links: ## Create symbolic links for dotfiles
	@echo "Creating symbolic links..."
	bash ./bin/link.sh

# プラットフォーム固有のセットアップ
termux-setup: ## Setup for Android Termux environment
	@echo "Setting up Termux environment..."
	bash ./bin/termux/init.sh

# 専用設定スクリプト
memolist-config: ## Configure note-taking system with optional Nextcloud sync
	@echo "Configuring memolist..."
	bash ./config_memolist.sh

zettelkasten-config: ## Setup Zettelkasten knowledge management
	@echo "Setting up Zettelkasten..."
	bash ./config_zettelkasten.sh

wezterm-install: ## Build and install WezTerm terminal from source
	@echo "Installing WezTerm..."
	bash ./install_wezterm.sh

yaskkserv2-build: ## Build Japanese SKK input method server
	@echo "Building yaskkserv2..."
	bash ./make_yaskkserv2.sh

# Flutter開発環境
flutter-setup: ## Install and setup Flutter development environment
	@echo "Setting up Flutter development environment..."
	bash ./bin/apps/flutter.sh

# Neovim管理コマンド
neovim-setup: ## Setup Neovim stable/nightly switcher
	@echo "Setting up Neovim version switcher..."
	bash ./bin/apps/neovim_switcher.sh setup

neovim-stable: ## Switch to Neovim stable version
	@echo "Switching to Neovim stable version..."
	bash ./bin/apps/neovim_switcher.sh stable

neovim-nightly: ## Switch to Neovim nightly version
	@echo "Switching to Neovim nightly version..."
	bash ./bin/apps/neovim_switcher.sh nightly

neovim-status: ## Show current Neovim version status
	@bash ./bin/apps/neovim_switcher.sh status

neovim-install: ## Install Neovim (usage: make neovim-install VERSION=stable/nightly)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-install VERSION=<stable|nightly>"; \
		echo "Example: make neovim-install VERSION=stable"; \
		echo "Example: make neovim-install VERSION=nightly"; \
	else \
		echo "Installing Neovim $(VERSION) version..."; \
		bash ./bin/apps/neovim_installer.sh install "$(VERSION)"; \
	fi

neovim-uninstall: ## Uninstall Neovim (usage: make neovim-uninstall VERSION=stable/nightly)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-uninstall VERSION=<stable|nightly>"; \
		echo "Example: make neovim-uninstall VERSION=stable"; \
		echo "Example: make neovim-uninstall VERSION=nightly"; \
	else \
		echo "Uninstalling Neovim $(VERSION) version..."; \
		bash ./bin/apps/neovim_installer.sh uninstall "$(VERSION)"; \
	fi

neovim-toggle: ## Toggle between stable and nightly versions
	@echo "Toggling Neovim version..."
	bash ./bin/apps/neovim_switcher.sh toggle

neovim-update: ## Update current Neovim version
	@echo "Updating current Neovim version..."
	bash ./bin/apps/neovim_switcher.sh update

# クイックエイリアスコマンド（超短縮形）
nvim-s: ## Quick switch to stable (alias for neovim-stable)
	@bash ./bin/apps/neovim_switcher.sh s

nvim-n: ## Quick switch to nightly (alias for neovim-nightly)
	@bash ./bin/apps/neovim_switcher.sh n

nvim-t: ## Quick toggle between versions (alias for neovim-toggle)
	@bash ./bin/apps/neovim_switcher.sh t

nvim-u: ## Quick update current version (alias for neovim-update)
	@bash ./bin/apps/neovim_switcher.sh u

# テストとメンテナンス
test: ## Run dotfiles functionality tests
	@echo "Running dotfiles tests..."
	bash ./bin/test.sh

status: ## Show current dotfiles status and configuration
	@echo "Dotfiles Status:"
	@echo "=================="
	@echo "Repository: $(shell pwd)"
	@echo "Platform: $(shell uname -s)"
	@echo "Architecture: $(shell uname -m)"
	@echo ""
	@echo "Git Status:"
	@git status --porcelain 2>/dev/null || echo "Not a git repository"
	@echo ""
	@echo "Configuration Status:"
	@bash -c 'source ./bin/lib/common.sh && source ./bin/lib/config_loader.sh && load_config && show_config' 2>/dev/null || echo "Configuration loading failed"

info: ## Display system and dotfiles information
	@echo "System Information:"
	@echo "==================="
	@echo "OS: $(shell uname -s)"
	@echo "Architecture: $(shell uname -m)"
	@echo "Hostname: $(shell hostname)"
	@echo "User: $(shell whoami)"
	@echo "Shell: $(shell echo $$SHELL)"
	@echo ""
	@echo "Dotfiles Information:"
	@echo "====================="
	@echo "Location: $(shell pwd)"
	@echo "Git branch: $(shell git branch --show-current 2>/dev/null || echo 'Not a git repository')"
	@echo "Last commit: $(shell git log -1 --format='%h - %s (%cr)' 2>/dev/null || echo 'No git history')"

clean: ## Clean up temporary files and caches
	@echo "Cleaning up temporary files..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.cache" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@rm -rf ./.dotfiles_backup/tmp* 2>/dev/null || true
	@echo "Cleanup completed."

# デバッグとトラブルシューティング
debug: ## Show debug information for troubleshooting
	@echo "Debug Information:"
	@echo "=================="
	@echo "Make version: $(MAKE_VERSION)"
	@echo "Shell: $(SHELL)"
	@echo "PATH: $(PATH)"
	@echo ""
	@echo "Available tools:"
	@echo "  git: $(shell command -v git 2>/dev/null || echo 'not found')"
	@echo "  curl: $(shell command -v curl 2>/dev/null || echo 'not found')"
	@echo "  zsh: $(shell command -v zsh 2>/dev/null || echo 'not found')"
	@echo "  nvim: $(shell command -v nvim 2>/dev/null || echo 'not found')"
	@echo ""
	@echo "Library status:"
	@bash -c 'source ./bin/lib/common.sh && echo "  common.sh: loaded"' 2>/dev/null || echo "  common.sh: failed to load"

# バリデーション
validate: ## Validate dotfiles configuration and structure
	@echo "Validating dotfiles configuration..."
	@bash -c 'source ./bin/lib/config_loader.sh && load_config && validate_config' || exit 1
	@echo "Validation completed successfully."

# 高度なコマンド
update: ## Update dotfiles and submodules
	@echo "Updating dotfiles..."
	@git pull origin main 2>/dev/null || echo "Git pull failed or not in a git repository"
	@git submodule update --init --recursive 2>/dev/null || echo "No submodules to update"
	@echo "Update completed."

backup: ## Create backup of current configuration
	@echo "Creating backup..."
	@BACKUP_DIR="$$HOME/.dotfiles_backup/full_backup_$(shell date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	cp -r . "$$BACKUP_DIR/" 2>/dev/null || true; \
	echo "Backup created at: $$BACKUP_DIR"

# フォント管理コマンド
fonts: ## Install recommended fonts for current platform
	@echo "Installing recommended fonts..."
	@bash -c 'source ./bin/lib/font_manager.sh && install_recommended_fonts developer'

fonts-list: ## List available and installed fonts
	@echo "Font installation status:"
	@bash -c 'source ./bin/lib/font_manager.sh && list_installed_fonts'

fonts-install: ## Install specific font (usage: make fonts-install FONT=font-name)
	@if [ -z "$(FONT)" ]; then \
		echo "Usage: make fonts-install FONT=<font-name>"; \
		echo "Available fonts:"; \
		bash -c 'source ./bin/lib/font_manager.sh && init_font_configs && for key in $${!FONT_CONFIGS[@]}; do echo "  $$key"; done | sort'; \
	else \
		echo "Installing font: $(FONT)"; \
		bash -c 'source ./bin/lib/font_manager.sh && install_font "$(FONT)"'; \
	fi

fonts-japanese: ## Install Japanese-focused font set
	@echo "Installing Japanese font set..."
	@bash -c 'source ./bin/lib/font_manager.sh && install_recommended_fonts japanese'

fonts-all: ## Install all available fonts
	@echo "Installing all available fonts..."
	@bash -c 'source ./bin/lib/font_manager.sh && install_recommended_fonts all'

# ghq関連コマンド
ghq-setup: ## Setup ghq for repository management
	@echo "Setting up ghq..."
	@bash bin/apps/ghq.sh

ghq-list: ## List all repositories managed by ghq
	@echo "Repositories managed by ghq:"
	@if command -v ghq >/dev/null 2>&1; then \
		ghq list; \
	else \
		echo "ghq is not installed. Run 'make ghq-setup' first."; \
	fi

ghq-get: ## Clone a repository with ghq (usage: make ghq-get REPO=github.com/user/repo)
	@if [ -z "$(REPO)" ]; then \
		echo "Usage: make ghq-get REPO=<repository-url>"; \
		echo "Example: make ghq-get REPO=github.com/user/repo"; \
	else \
		echo "Cloning repository: $(REPO)"; \
		ghq get "$(REPO)"; \
	fi

tmux-reload: ## Reload tmux configuration
	@echo "Reloading tmux configuration..."
	@if tmux info >/dev/null 2>&1; then \
		tmux source-file ~/.config/tmux/tmux.conf; \
		echo "✅ tmux configuration reloaded"; \
	else \
		echo "❌ tmux is not running"; \
	fi
