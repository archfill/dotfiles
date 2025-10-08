# Dotfiles Management Makefile
# 
# このMakefileは、dotfilesの各種操作を簡単に実行するためのコマンドを提供します。
# 使用方法: make <target>
# ヘルプ: make help

.PHONY: all help init config links test clean status info fonts fonts-list fonts-install flutter-setup neovim-install neovim-switch neovim-uninstall neovim-status neovim-update appimage-list appimage-list-installed appimage-install-all appimage-update-all appimage-uninstall-all appimage-install appimage-update appimage-uninstall appimage-status java-setup rust-setup go-setup php-setup ruby-setup terraform-setup docker-setup core-sdks web-sdks devops-sdks all-sdks sdk-status sdk-versions sdk-paths dev-environment
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
	bash ./bin/apps/devops/flutter.sh

# ===== Neovim管理システム =====
neovim-install: ## Install Neovim version (usage: make neovim-install VERSION=stable/nightly)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-install VERSION=<stable|nightly>"; \
		echo "Examples:"; \
		echo "  make neovim-install VERSION=stable"; \
		echo "  make neovim-install VERSION=nightly"; \
		echo ""; \
		bash ./bin/neovim-unified-manager.sh status; \
	else \
		echo "Installing Neovim $(VERSION) version..."; \
		bash ./bin/neovim-unified-manager.sh install "$(VERSION)"; \
	fi

neovim-switch: ## Switch Neovim version (usage: make neovim-switch VERSION=stable/nightly)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-switch VERSION=<stable|nightly>"; \
		echo "Examples:"; \
		echo "  make neovim-switch VERSION=stable"; \
		echo "  make neovim-switch VERSION=nightly"; \
		echo ""; \
		bash ./bin/neovim-unified-manager.sh status; \
	else \
		echo "Switching to Neovim $(VERSION)..."; \
		bash ./bin/neovim-unified-manager.sh switch "$(VERSION)"; \
	fi

neovim-uninstall: ## Uninstall Neovim version (usage: make neovim-uninstall VERSION=stable/nightly/all)
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make neovim-uninstall VERSION=<stable|nightly|all>"; \
		echo "Examples:"; \
		echo "  make neovim-uninstall VERSION=stable"; \
		echo "  make neovim-uninstall VERSION=nightly"; \
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

# ===== AppImage一括管理システム =====
# 一括操作
appimage-list: ## List all available AppImage scripts
	@bash ./bin/appimage-manager.sh list

appimage-list-installed: ## List installed AppImages with details
	@bash ./bin/appimage-manager.sh list-installed

appimage-install-all: ## Install all available AppImages
	@bash ./bin/appimage-manager.sh install-all

appimage-update-all: ## Update all installed AppImages
	@bash ./bin/appimage-manager.sh update-all

appimage-uninstall-all: ## Uninstall all AppImages
	@bash ./bin/appimage-manager.sh uninstall-all

# 個別操作（簡潔な形式）
appimage-install: ## Install specific AppImage (usage: make appimage-install APP=winboat)
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make appimage-install APP=<app-name>"; \
		echo "Example: make appimage-install APP=winboat"; \
		echo ""; \
		bash ./bin/appimage-manager.sh list; \
	else \
		bash ./bin/appimage-manager.sh install "$(APP)"; \
	fi

appimage-update: ## Update specific AppImage (usage: make appimage-update APP=winboat)
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make appimage-update APP=<app-name>"; \
		echo "Example: make appimage-update APP=winboat"; \
		echo ""; \
		bash ./bin/appimage-manager.sh list; \
	else \
		bash ./bin/appimage-manager.sh update "$(APP)"; \
	fi

appimage-uninstall: ## Uninstall specific AppImage (usage: make appimage-uninstall APP=winboat)
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make appimage-uninstall APP=<app-name>"; \
		echo "Example: make appimage-uninstall APP=winboat"; \
		echo ""; \
		bash ./bin/appimage-manager.sh list; \
	else \
		bash ./bin/appimage-manager.sh uninstall "$(APP)"; \
	fi

appimage-status: ## Show status of specific AppImage (usage: make appimage-status APP=winboat)
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make appimage-status APP=<app-name>"; \
		echo "Example: make appimage-status APP=winboat"; \
		echo ""; \
		bash ./bin/appimage-manager.sh list; \
	else \
		bash ./bin/appimage-manager.sh status "$(APP)"; \
	fi

# テストとメンテナンス
test: ## Run dotfiles functionality tests
	@echo "Running dotfiles tests..."
	bash ./bin/test.sh

# === 保守・メンテナンス管理 ===
cleanup-symlinks: ## Clean up broken symbolic links
	@echo "Cleaning up broken symbolic links..."
	bash ./bin/cleanup-symlinks.sh

cleanup-symlinks-dry: ## Show broken symbolic links without removing them
	@echo "Checking for broken symbolic links (dry run)..."
	bash ./bin/cleanup-symlinks.sh --dry-run

verify-links: ## Check status of all symbolic links
	@echo "Verifying symbolic links status..."
	bash ./bin/verify-links.sh

verify-links-broken: ## Show only broken symbolic links
	@echo "Checking for broken symbolic links..."
	bash ./bin/verify-links.sh --broken-only

verify-links-dotfiles: ## Show only dotfiles-related symbolic links
	@echo "Checking dotfiles-related symbolic links..."
	bash ./bin/verify-links.sh --dotfiles-only

archive-config: ## Archive configuration before removal (usage: make archive-config CONFIG=name REASON="reason")
	@if [ -z "$(CONFIG)" ]; then \
		echo "Usage: make archive-config CONFIG=<config-name> [REASON=\"reason\"]"; \
		echo "Example: make archive-config CONFIG=yabai-skhd REASON=\"Migrated to Aerospace\""; \
		exit 1; \
	else \
		echo "Archiving configuration: $(CONFIG)"; \
		bash ./bin/archive-config.sh "$(CONFIG)" "$(REASON)"; \
	fi

archive-config-dry: ## Preview archive operation without executing
	@if [ -z "$(CONFIG)" ]; then \
		echo "Usage: make archive-config-dry CONFIG=<config-name> [REASON=\"reason\"]"; \
		echo "Example: make archive-config-dry CONFIG=yabai-skhd REASON=\"Migrated to Aerospace\""; \
		exit 1; \
	else \
		echo "Previewing archive operation for: $(CONFIG)"; \
		bash ./bin/archive-config.sh --dry-run "$(CONFIG)" "$(REASON)"; \
	fi

maintenance-status: ## Show comprehensive maintenance status
	@echo "=== Dotfiles Maintenance Status ==="
	@echo ""
	@echo "📊 Repository Status:"
	@echo "Repository: $(shell pwd)"
	@echo "Git branch: $(shell git branch --show-current 2>/dev/null || echo 'Not a git repository')"
	@echo "Last commit: $(shell git log -1 --format='%h - %s (%cr)' 2>/dev/null || echo 'No git history')"
	@echo ""
	@echo "🔗 Symbolic Links Summary:"
	@bash ./bin/verify-links.sh 2>/dev/null || echo "Link verification failed"
	@echo ""
	@echo "📁 Archive Branches:"
	@git branch -a | grep archive/ 2>/dev/null || echo "No archive branches found"

maintenance-full: cleanup-symlinks verify-links ## Run complete maintenance cycle
	@echo "✅ Full maintenance cycle completed!"
	@echo ""
	@echo "📋 Summary:"
	@echo "  • Cleaned up broken symbolic links"
	@echo "  • Verified all symbolic links"
	@echo ""
	@echo "💡 For more detailed status: make maintenance-status"

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
	@if [[ "${SKIP_FONT_INSTALL:-0}" == "1" ]]; then \
		echo "Font installation skipped (SKIP_FONT_INSTALL=1)"; \
	else \
		echo "Installing recommended fonts..."; \
		bash -c 'source ./bin/lib/font_manager.sh && install_recommended_fonts developer'; \
	fi

fonts-list: ## List available and installed fonts
	@echo "Font installation status:"
	@bash -c 'source ./bin/lib/font_manager.sh && list_installed_fonts'

fonts-install: ## Install specific font (usage: make fonts-install FONT=font-name)
	@if [[ "${SKIP_FONT_INSTALL:-0}" == "1" ]]; then \
		echo "Font installation skipped (SKIP_FONT_INSTALL=1)"; \
	elif [ -z "$(FONT)" ]; then \
		echo "Usage: make fonts-install FONT=<font-name>"; \
		echo "Available fonts:"; \
		bash -c 'source ./bin/lib/font_manager.sh && init_font_configs && for key in $${!FONT_CONFIGS[@]}; do echo "  $$key"; done | sort'; \
	else \
		echo "Installing font: $(FONT)"; \
		bash -c 'source ./bin/lib/font_manager.sh && install_font "$(FONT)"'; \
	fi

fonts-japanese: ## Install Japanese-focused font set
	@if [[ "${SKIP_FONT_INSTALL:-0}" == "1" ]]; then \
		echo "Font installation skipped (SKIP_FONT_INSTALL=1)"; \
	else \
		echo "Installing Japanese font set..."; \
		bash -c 'source ./bin/lib/font_manager.sh && install_recommended_fonts japanese'; \
	fi

fonts-all: ## Install all available fonts
	@if [[ "${SKIP_FONT_INSTALL:-0}" == "1" ]]; then \
		echo "Font installation skipped (SKIP_FONT_INSTALL=1)"; \
	else \
		echo "Installing all available fonts..."; \
		bash -c 'source ./bin/lib/font_manager.sh && install_recommended_fonts all'; \
	fi

# SketchyBar関連コマンド
sketchybar-install: ## Install SketchyBar with SbarLua support
	@echo "Setting up SketchyBar with SbarLua..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		echo "🎨 Installing SketchyBar and SbarLua..."; \
		if ! command -v sketchybar >/dev/null 2>&1; then \
			echo "Installing SketchyBar via Homebrew..."; \
			brew tap FelixKratz/formulae && brew install sketchybar; \
		fi; \
		bash bin/install-methods/binary/sketchybar.sh; \
		echo "✅ SketchyBar setup completed!"; \
		echo ""; \
		echo "💡 Next steps:"; \
		echo "  • Test installation: make sketchybar-test"; \
		echo "  • Start SketchyBar: brew services start sketchybar"; \
	else \
		echo "❌ SketchyBar is only available on macOS"; \
		exit 1; \
	fi

sketchybar-uninstall: ## Uninstall SbarLua
	@echo "Uninstalling SbarLua..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		bash bin/install-methods/binary/sketchybar.sh uninstall; \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi


sketchybar-test: ## Test SketchyBar Lua configuration (usage: make sketchybar-test [MODE=full/syntax/performance/quick])
	@echo "Testing SketchyBar Lua configuration..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		bash bin/sketchybar-test.sh $(MODE); \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

# ghq関連コマンド
ghq-setup: ## Setup ghq for repository management
	@echo "Setting up ghq..."
	@bash ./bin/apps/ghq.sh

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
		echo ""; \
		bash ./bin/init.sh; \
		echo ""; \
		echo "✅ macOS setup completed!"; \
		echo ""; \
		echo "💡 Next steps:"; \
		echo "  • Install Neovim: make neovim-install VERSION=stable"; \
		echo "  • Run tests: make macos-test"; \
		echo "  • Check status: make neovim-status"; \
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
		echo ""; \
		DOTFILES_INSTALL_MODE=essential bash ./bin/init.sh; \
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
	@bash ./bin/apps/03-java-sdkman.sh

rust-setup: ## Install Rust stable toolchain via rustup
	@echo "Installing Rust stable toolchain via rustup..."
	@bash ./bin/apps/02-rust-rustup.sh

go-setup: ## Install Go latest via g version manager
	@echo "Installing Go latest via g version manager..."
	@bash ./bin/apps/01-go-g.sh

php-setup: ## Install PHP 8.3 via APT package manager
	@echo "Installing PHP 8.3 via APT package manager..."
	@bash ./bin/apps/php-apt.sh

ruby-setup: ## Install Ruby 3.2 via rbenv
	@echo "Installing Ruby 3.2 via rbenv..."
	@bash ./bin/apps/ruby-rbenv.sh

terraform-setup: ## Install Terraform CLI
	@echo "Installing Terraform CLI..."
	@bash ./bin/apps/51-terraform.sh

docker-setup: ## Setup Docker Engine
	@echo "Setting up Docker Engine..."
	@bash ./bin/apps/50-docker.sh

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

# ===== Neovim管理システム完了 =====

# ===== ログ付き実行コマンド =====
init-log: ## Complete dotfiles initialization with logging
	@bash -c 'source ./bin/lib/logger.sh && run_with_log "init" bash ./bin/init.sh'

apps-setup-log: ## Run apps setup with logging
	@bash -c 'source ./bin/lib/logger.sh && run_with_log "apps_setup" bash ./bin/apps_setup.sh'

# ===== ログ管理コマンド =====
logs-list: ## List all log files
	@echo "Available log files:"
	@ls -lht .logs/*.log 2>/dev/null | head -20 || echo "No log files found"

logs-latest: ## Show the latest log file (last 100 lines)
	@echo "=== Latest Log File (last 100 lines) ==="
	@ls -t .logs/*.log 2>/dev/null | head -1 | xargs tail -100 || echo "No log files found"

logs-clean: ## Clean up log files older than 30 days
	@echo "Cleaning up old log files (30+ days)..."
	@find .logs -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true
	@echo "Cleanup completed"

logs-view: ## View specific log file (usage: make logs-view LOG=filename)
	@if [ -z "$(LOG)" ]; then \
		echo "Usage: make logs-view LOG=<filename>"; \
		echo ""; \
		echo "Available logs:"; \
		ls .logs/*.log 2>/dev/null | xargs -n1 basename || echo "No logs found"; \
	else \
		less .logs/$(LOG); \
	fi

