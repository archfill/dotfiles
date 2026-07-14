# Dotfiles Management Makefile
# 
# このMakefileは、dotfilesの各種操作を簡単に実行するためのコマンドを提供します。
# 使用方法: make <target>
# ヘルプ: make help

.PHONY: all help init init-log config update backup clean status info debug validate \
	nix-rebuild nix-diff nix-bootloader nix-clean nix-update codex-update codex-bump orca-update orca-bump \
	rebuild diff rebuild-bootloader \
	hyprland-status monitors monitors-auto monitors-single monitors-dual \
	sketchybar-test \
	git-health tmux-reload \
	docker-setup \
	logs-list logs-latest logs-clean logs-view
.DEFAULT_GOAL := help

# デフォルトターゲット
all: init

# ヘルプ表示
help: ## Show this help message
	@echo "Dotfiles Management Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make init          # Complete dotfiles setup"
	@echo "  make nix-diff      # Preview Nix changes"
	@echo "  make rebuild       # Alias for nix-rebuild"
	@echo "  make config        # Setup Git configuration"
	@echo "  make monitors      # Configure monitors (interactive)"

# 基本セットアップ
init: ## Complete dotfiles initialization and setup
	@echo "Starting complete dotfiles initialization..."
	NIX_ATTR="$(NIX_ATTR)" DOTFILES_INSTALL_MODE="$(DOTFILES_INSTALL_MODE)" DOTFILES_LEGACY_INSTALL="$(DOTFILES_LEGACY_INSTALL)" bash ./bin/init.sh

init-log: ## Complete dotfiles initialization with logging
	@bash -c 'source ./bin/lib/logger.sh && run_with_log "init" bash ./bin/init.sh'

config: ## Setup Git configuration with personal settings
	@echo "Setting up Git configuration..."
	bash ./bin/config.sh

update: ## Update dotfiles and submodules (fast-forward only)
	@echo "Updating dotfiles..."
	@git pull --ff-only origin main
	@git submodule update --init --recursive
	@echo "Update completed."

backup: ## Create backup of current configuration
	@echo "Creating backup..."
	@BACKUP_DIR="$$HOME/.dotfiles_backup/full_backup_$(shell date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	cp -r . "$$BACKUP_DIR/" 2>/dev/null || true; \
	echo "Backup created at: $$BACKUP_DIR"

clean: ## Clean up temporary files and caches
	@echo "Cleaning up temporary files..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.cache" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@rm -rf ./.dotfiles_backup/tmp* 2>/dev/null || true
	@echo "Cleanup completed."

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

validate: ## Validate dotfiles configuration and structure
	@echo "Validating dotfiles configuration..."
	@bash -c 'source ./bin/lib/config_loader.sh && load_config && validate_config' || exit 1
	@echo "Validation completed successfully."

# ─── Nix 運用 (nh 経由) ─────────────────────────────────────────────
# nh が PATH に入っている前提 (home.packages.nh で配布)。
# 切替対象は OS / Linux ディストロで自動分岐。NixOS なら nh os、
# macOS なら nh darwin、それ以外 (Arch / Ubuntu / WSL) は nh home。
NIX_FLAKE := $(CURDIR)/nix
NIX_FLAKE_REF := $(NIX_FLAKE)$(if $(NIX_ATTR),#$(NIX_ATTR),)
NH_TARGET := $(shell uname -s | grep -qi darwin && echo darwin || ([ -e /etc/NIXOS ] && echo os || echo home))

nix-rebuild: ## Nix flake を反映 (nh で OS 自動判定)
	nh $(NH_TARGET) switch $(NIX_FLAKE_REF)

nix-bootloader: ## NixOS の bootloader も再インストールして反映
	@if [ "$(NH_TARGET)" != "os" ]; then \
		echo "nix-bootloader is only for NixOS"; \
		exit 1; \
	fi
	nh os switch $(NIX_FLAKE_REF) --install-bootloader

nix-diff: ## 次の switch で何が変わるかを表示 (適用しない)
	nh $(NH_TARGET) switch $(NIX_FLAKE_REF) --dry

nix-clean: ## 古い generation を 5 世代残して掃除
	nh clean all --keep 5

nix-update: codex-update orca-update ## AI CLI と flake.lock を更新してから switch
	nh $(NH_TARGET) switch $(NIX_FLAKE_REF) -u

codex-update: ## Codex CLI の最新 release を取得して Nix package 定義を更新
	@bash ./bin/codex-update.sh $(VERSION)

codex-bump: codex-update ## Alias for codex-update (usage: make codex-bump VERSION=0.142.0)

orca-update: ## Orca の最新 release を取得して Nix package 定義を更新
	@bash ./bin/orca-update.sh $(VERSION)

orca-bump: orca-update ## Alias for orca-update (usage: make orca-bump VERSION=1.4.139)

rebuild: nix-rebuild
rebuild-bootloader: nix-bootloader
diff: nix-diff

hyprland-status: ## Check Hyprland installation and configuration status
	@echo "Checking Hyprland status..."
	@echo ""
	@echo "=== Package Status ==="
	@if command -v Hyprland >/dev/null 2>&1; then \
		echo "✅ Hyprland: $$(Hyprland --version 2>&1 | head -1)"; \
	else \
		echo "❌ Hyprland: Not installed"; \
	fi
	@if command -v caelestia-shell >/dev/null 2>&1; then \
		echo "✅ caelestia-shell: installed"; \
	else \
		echo "❌ caelestia-shell: Not installed"; \
	fi
	@if command -v rofi >/dev/null 2>&1; then \
		echo "✅ rofi: $$(rofi -version 2>&1 | head -1) (clipboard/cheatsheet)"; \
	else \
		echo "❌ rofi: Not installed"; \
	fi
	@echo ""
	@echo "=== Configuration Files ==="
	@if [ -f ~/.config/hypr/hyprland.conf ]; then \
		echo "✅ hyprland.conf: exists"; \
	else \
		echo "❌ hyprland.conf: missing"; \
	fi
	@if [ -w ~/.config/caelestia/shell.json ]; then \
		echo "✅ caelestia config: writable"; \
	else \
		echo "❌ caelestia config: missing or read-only"; \
	fi
	@if [ -d ~/.config/rofi ]; then \
		echo "✅ rofi config: exists (fallback menus)"; \
	else \
		echo "❌ rofi config: missing"; \
	fi
	@if systemctl --user is-active --quiet caelestia.service; then \
		echo "✅ caelestia.service: active"; \
	else \
		echo "❌ caelestia.service: inactive"; \
	fi
	@echo ""
	@echo "=== NVIDIA Status ==="
	@if lspci | grep -i nvidia >/dev/null 2>&1; then \
		echo "🎮 NVIDIA GPU detected"; \
		if [ -f /sys/module/nvidia_drm/parameters/modeset ]; then \
			MODESET=$$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || sudo -n cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || true); \
			if [ "$$MODESET" = "Y" ]; then \
				echo "✅ nvidia-drm.modeset=1: configured"; \
			elif grep -q 'nvidia-drm.modeset=1' /proc/cmdline 2>/dev/null; then \
				echo "✅ nvidia-drm.modeset=1: configured"; \
			elif [ -z "$$MODESET" ]; then \
				echo "⚠️  nvidia-drm.modeset=1: unable to verify"; \
			else \
				echo "⚠️  nvidia-drm.modeset=1: NOT configured"; \
			fi; \
		else \
			echo "⚠️  NVIDIA driver not loaded"; \
		fi; \
	else \
		echo "ℹ️  No NVIDIA GPU detected"; \
	fi

monitors: ## Auto-detect and configure monitors interactively (recommended)
	@echo "Detecting monitors and showing configuration menu..."
	@bash ~/.config/hypr/auto-detect-monitors.sh

monitors-auto: ## Auto-detect and configure monitors without confirmation
	@echo "Auto-detecting and configuring monitors..."
	@bash ~/.config/hypr/auto-detect-monitors.sh --auto

monitors-single: ## Force single display mode
	@echo "Configuring for single display mode..."
	@bash ~/.config/hypr/auto-detect-monitors.sh --mode single

monitors-dual: ## Force dual display mode
	@echo "Configuring for dual display mode..."
	@bash ~/.config/hypr/auto-detect-monitors.sh --mode dual

sketchybar-test: ## Test SketchyBar Lua configuration (usage: make sketchybar-test [MODE=full/syntax/performance/quick])
	@echo "Testing SketchyBar Lua configuration..."
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		bash bin/sketchybar-test.sh $(MODE); \
	else \
		echo "❌ This command is only for macOS"; \
		exit 1; \
	fi

git-health: ## Check health of all ghq-managed repositories
	@bash ./bin/git-health.sh

tmux-reload: ## Reload tmux configuration
	@echo "Reloading tmux configuration..."
	@if tmux info >/dev/null 2>&1; then \
		tmux source-file ~/.config/tmux/tmux.conf; \
		echo "✅ tmux configuration reloaded"; \
	else \
		echo "❌ tmux is not running"; \
	fi

docker-setup: ## Setup Docker Engine
	@echo "Setting up Docker Engine..."
	@bash ./bin/docker-setup.sh

# ===== Neovim管理システム完了 =====

# ===== ログ管理コマンド =====
logs-list: ## List all log files
	@echo "Available log files:"
	@if ls .logs/*.log >/dev/null 2>&1; then \
		ls -lht .logs/*.log | head -20; \
	else \
		echo "No log files found"; \
	fi

logs-latest: ## Show the latest log file (last 100 lines)
	@echo "=== Latest Log File (last 100 lines) ==="
	@if latest=$$(ls -t .logs/*.log 2>/dev/null | head -1) && [ -n "$$latest" ]; then \
		tail -100 "$$latest"; \
	else \
		echo "No log files found"; \
	fi

logs-clean: ## Clean up log files older than 30 days
	@echo "Cleaning up old log files (30+ days)..."
	@find .logs -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true
	@echo "Cleanup completed"

logs-view: ## View specific log file (usage: make logs-view LOG=filename)
	@if [ -z "$(LOG)" ]; then \
		echo "Usage: make logs-view LOG=<filename>"; \
		echo ""; \
		echo "Available logs:"; \
		if ls .logs/*.log >/dev/null 2>&1; then \
			ls .logs/*.log | xargs -n1 basename; \
		else \
			echo "No logs found"; \
		fi; \
	else \
		less .logs/$(LOG); \
	fi
