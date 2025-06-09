# Dotfiles Management Makefile
# 
# このMakefileは、dotfilesの各種操作を簡単に実行するためのコマンドを提供します。
# 使用方法: make <target>
# ヘルプ: make help

.PHONY: all help init config links test clean status info
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

# Neovim関連
neovim-install: ## Install Neovim on Linux systems
	@echo "Installing Neovim..."
	bash ./bin/linux/apps/neovim_install.sh

neovim-uninstall: ## Remove Neovim installation
	@echo "Uninstalling Neovim..."
	bash ./bin/linux/apps/neovim_uninstall.sh

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
