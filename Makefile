# Dotfiles Management Makefile
# 
# このMakefileは、dotfilesの各種操作を簡単に実行するためのコマンドを提供します。
# 使用方法: make <target>
# ヘルプ: make help

.PHONY: all help init config links test clean status info fonts fonts-list fonts-install flutter-setup neovim-install neovim-switch neovim-uninstall neovim-status neovim-update neovim-deps neovim-head-build neovim-head-update neovim-head-status neovim-head-auto-install neovim-head-auto-status neovim-head-clean java-setup rust-setup go-setup php-setup ruby-setup terraform-setup docker-setup core-sdks web-sdks devops-sdks all-sdks sdk-status sdk-versions sdk-paths dev-environment
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

# ===== 統一Neovim管理システム（推奨） =====
neovim-install: ## Install Neovim version (usage: make neovim-install VERSION=stable/nightly/head)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-install VERSION=<stable|nightly|head>"; \
		echo "Examples:"; \
		echo "  make neovim-install VERSION=stable"; \
		echo "  make neovim-install VERSION=nightly"; \
		echo "  make neovim-install VERSION=head"; \
		echo ""; \
		bash ./bin/neovim-unified-manager.sh status; \
	else \
		echo "Installing Neovim $(VERSION) version..."; \
		if ! bash ./bin/neovim-unified-manager.sh install "$(VERSION)"; then \
			echo "❌ Installation failed. Check logs and dependencies."; \
			echo "For HEAD version, ensure you have: git, cmake, make, ninja, gcc, g++, pkg-config"; \
			exit 1; \
		fi; \
	fi

neovim-switch: ## Switch Neovim version (usage: make neovim-switch VERSION=stable/nightly/head)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-switch VERSION=<stable|nightly|head>"; \
		echo "Examples:"; \
		echo "  make neovim-switch VERSION=stable"; \
		echo "  make neovim-switch VERSION=nightly"; \
		echo "  make neovim-switch VERSION=head"; \
		echo ""; \
		bash ./bin/neovim-unified-manager.sh status; \
	else \
		echo "Switching to Neovim $(VERSION)..."; \
		bash ./bin/neovim-unified-manager.sh switch "$(VERSION)"; \
	fi

neovim-uninstall: ## Uninstall Neovim version (usage: make neovim-uninstall VERSION=stable/nightly/head/all)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-uninstall VERSION=<stable|nightly|head|all>"; \
		echo "Examples:"; \
		echo "  make neovim-uninstall VERSION=stable"; \
		echo "  make neovim-uninstall VERSION=nightly"; \
		echo "  make neovim-uninstall VERSION=head"; \
		echo "  make neovim-uninstall VERSION=all"; \
		echo ""; \
		bash ./bin/neovim-unified-manager.sh status; \
	else \
		echo "Uninstalling Neovim $(VERSION)..."; \
		bash ./bin/neovim-unified-manager.sh uninstall "$(VERSION)"; \
	fi

neovim-status: ## Show unified status of all Neovim versions
	@bash ./bin/neovim-unified-manager.sh status

neovim-update: ## Update current active Neovim version
	@echo "Updating current Neovim version..."
	@bash ./bin/neovim-unified-manager.sh update

neovim-deps: ## Check and install build dependencies for HEAD version
	@echo "Checking build dependencies..."
	@bash ./bin/neovim-unified-manager.sh deps


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

# ===== Neovim HEAD 詳細管理（上級者向け） =====
neovim-head-build: ## [ADVANCED] Build Neovim from latest HEAD (direct tracker)
	@echo "Building Neovim from latest HEAD..."
	@bash ./bin/neovim-head-tracker.sh build

neovim-head-update: ## [ADVANCED] Update Neovim HEAD only if changes are available
	@echo "Checking for Neovim HEAD updates..."
	@bash ./bin/neovim-head-tracker.sh update

neovim-head-status: ## [ADVANCED] Show Neovim HEAD build status and version info
	@bash ./bin/neovim-head-tracker.sh status

neovim-head-clean: ## [ADVANCED] Clean Neovim HEAD build artifacts
	@echo "Cleaning Neovim HEAD build artifacts..."
	@bash ./bin/neovim-head-tracker.sh clean

neovim-head-clean-all: ## [ADVANCED] Clean all Neovim HEAD data and rebuild from scratch
	@echo "Cleaning all Neovim HEAD data..."
	@bash ./bin/neovim-head-tracker.sh clean-all

# ===== 自動更新システム =====
neovim-head-auto-install: ## Install automatic Neovim HEAD update system
	@echo "Installing Neovim HEAD auto-update system..."
	@echo "Choose update method:"
	@echo "  1) Systemd timer (recommended for systemd systems)"
	@echo "  2) Cron job (traditional method)"
	@read -p "Enter choice [1-2]: " choice; \
	case $$choice in \
		1) bash ./bin/neovim-auto-updater.sh install-systemd daily ;; \
		2) bash ./bin/neovim-auto-updater.sh install-cron "0 2 * * *" ;; \
		*) echo "Invalid choice. Use 'bash ./bin/neovim-auto-updater.sh' manually." ;; \
	esac

neovim-head-auto-status: ## Show Neovim HEAD auto-update system status
	@bash ./bin/neovim-auto-updater.sh status

neovim-head-auto-uninstall: ## Remove Neovim HEAD auto-update system
	@echo "Removing auto-update system..."
	@bash ./bin/neovim-auto-updater.sh uninstall

# ===== Neovim HEAD 高度なコマンド =====
neovim-head-deps-check: ## Check build dependencies for Neovim HEAD
	@echo "Checking Neovim HEAD build dependencies..."
	@bash ./bin/neovim-head-tracker.sh check

neovim-head-force-rebuild: ## Force complete rebuild of Neovim HEAD
	@echo "Force rebuilding Neovim HEAD..."
	@bash ./bin/neovim-head-tracker.sh clean-all
	@bash ./bin/neovim-head-tracker.sh build

neovim-head-info: ## Show detailed information about Neovim HEAD setup
	@echo "=== Neovim HEAD Information ==="
	@echo ""
	@bash ./bin/neovim-head-tracker.sh status
	@echo ""
	@echo "=== Auto-Update Status ==="
	@bash ./bin/neovim-auto-updater.sh status


# ===== macOS特化コマンド =====
macos-setup: ## Complete macOS development environment setup (dotfiles + apps + neovim)
	@echo "Setting up complete macOS development environment..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		echo "🍎 Starting comprehensive macOS setup..."; \
		echo ""; \
		echo "📋 This will install:"; \
		echo "  • Dotfiles configuration"; \
		echo "  • Homebrew packages and casks"; \
		echo "  • Development tools"; \
		echo "  • Fonts"; \
		echo "  • Neovim build dependencies"; \
		echo ""; \
		bash ./bin/init.sh; \
		echo ""; \
		echo "🔧 Installing Neovim build dependencies..."; \
		bash ./bin/neovim-unified-manager.sh deps; \
		echo ""; \
		echo "✅ macOS setup completed!"; \
		echo ""; \
		echo "💡 Next steps:"; \
		echo "  • Install Neovim HEAD: make neovim-install VERSION=head"; \
		echo "  • Run tests: make macos-test"; \
		echo "  • Check status: make neovim-status"; \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

macos-setup-minimal: ## Setup only Neovim build dependencies on macOS
	@echo "Setting up minimal macOS environment (Neovim dependencies only)..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		bash ./bin/neovim-unified-manager.sh deps; \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

macos-setup-essential: ## Setup essential macOS development environment
	@echo "Setting up essential macOS development environment..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		echo "🍎 Starting essential macOS setup..."; \
		echo ""; \
		echo "📋 This will install:"; \
		echo "  • Essential development tools"; \
		echo "  • Programming languages (uv, volta, etc.)"; \
		echo "  • Core utilities and GUI apps"; \
		echo "  • Neovim build dependencies"; \
		echo ""; \
		DOTFILES_INSTALL_MODE=essential bash ./bin/init.sh; \
		bash ./bin/neovim-unified-manager.sh deps; \
		echo ""; \
		echo "✅ Essential macOS setup completed!"; \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

macos-packages-minimal: ## Install minimal Homebrew packages only
	@echo "Installing minimal Homebrew packages..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		DOTFILES_INSTALL_MODE=minimal bash ./bin/mac/brew.sh; \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

macos-test: ## Run macOS-specific environment tests
	@echo "Running macOS tests..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		bash ./bin/test-macos.sh; \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

# ===== Development SDKs Management =====
# Individual SDK setup commands
java-setup: ## Install Java 21 LTS via SDKMAN!
	@echo "Installing Java 21 LTS via SDKMAN!..."
	@bash ./bin/apps/java-sdkman.sh

rust-setup: ## Install Rust stable toolchain via rustup
	@echo "Installing Rust stable toolchain via rustup..."
	@bash ./bin/apps/rust-rustup.sh

go-setup: ## Install Go latest via g version manager
	@echo "Installing Go latest via g version manager..."
	@bash ./bin/apps/go-g.sh

php-setup: ## Install PHP 8.3 via phpenv
	@echo "Installing PHP 8.3 via phpenv..."
	@bash ./bin/apps/php-phpenv.sh

ruby-setup: ## Install Ruby 3.2 via rbenv
	@echo "Installing Ruby 3.2 via rbenv..."
	@bash ./bin/apps/ruby-rbenv.sh

terraform-setup: ## Install Terraform CLI
	@echo "Installing Terraform CLI..."
	@bash ./bin/apps/terraform.sh

docker-setup: ## Setup Docker Engine
	@echo "Setting up Docker Engine..."
	@bash ./bin/apps/docker.sh

# Grouped SDK setup commands
core-sdks: java-setup rust-setup go-setup ## Install core development SDKs (Java, Rust, Go)
	@echo "✅ Core SDKs installation completed!"

web-sdks: php-setup ruby-setup ## Install web development SDKs (PHP, Ruby)
	@echo "✅ Web development SDKs installation completed!"

devops-sdks: terraform-setup docker-setup ## Install DevOps tools (Terraform, Docker)
	@echo "✅ DevOps tools installation completed!"

all-sdks: core-sdks web-sdks devops-sdks ## Install all supported SDKs and tools
	@echo "🚀 All SDKs and development tools installation completed!"
	@echo ""
	@echo "📊 Run 'make sdk-status' to verify installations"

# SDK status and management
sdk-status: ## Check all SDK installation status
	@echo "Checking SDK installation status..."
	@zsh -c 'source ~/.config/zsh/zshrc/sdk.zsh && sdk_status'

sdk-versions: ## Show installed SDK versions in compact format
	@echo "Showing installed SDK versions..."
	@zsh -c 'source ~/.config/zsh/zshrc/sdk.zsh && sdk_versions'

sdk-paths: ## Show SDK environment variables and paths
	@echo "SDK environment variables:"
	@zsh -c 'source ~/.config/zsh/zshrc/sdk.zsh && sdk_paths'

# Quick environment setup
dev-environment: init all-sdks ## Complete development environment setup (dotfiles + all SDKs)
	@echo "🎉 Complete development environment setup finished!"
	@echo ""
	@echo "📋 What was installed:"
	@echo "  • Dotfiles configuration"
	@echo "  • Java 21 LTS (SDKMAN!)"
	@echo "  • Rust stable (rustup)"
	@echo "  • Go latest (g)"
	@echo "  • PHP 8.3 (phpenv)"
	@echo "  • Ruby 3.2 (rbenv)"
	@echo "  • Terraform CLI"
	@echo "  • Docker Engine setup"
	@echo "  • Node.js (volta - existing)"
	@echo "  • Python (uv - existing)"
	@echo "  • Flutter SDK (existing)"
	@echo ""
	@echo "🔧 Next steps:"
	@echo "  • Restart your shell: exec $$SHELL"
	@echo "  • Check status: make sdk-status"
	@echo "  • Install Neovim LSP tools: nvim and run :MasonInstallEssentials"

# ===== Neovim統一管理システム完了 =====
# 非推奨エイリアスコマンドを削除し、統一コマンドのみ提供
