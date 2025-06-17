#!/usr/bin/env bash
# neovim-unified-manager.sh
# Neovim統合管理システム（stable/nightly/HEADの統一管理）

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/common.sh
source "$DOTFILES_DIR/bin/lib/common.sh"
# shellcheck source=lib/config_loader.sh
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# ===== 定数定義 =====
readonly NVIM_STATE_FILE="$HOME/.neovim_unified_state"
readonly NVIM_BIN_DIR="$HOME/.local/bin"
readonly NVIM_CONFIG_DIR="$HOME/.config"

# バイナリパス
readonly NVIM_STABLE_BIN="$NVIM_BIN_DIR/nvim-stable"
readonly NVIM_NIGHTLY_BIN="$NVIM_BIN_DIR/nvim-nightly"
readonly NVIM_HEAD_BIN="$NVIM_BIN_DIR/nvim"  # HEAD版は標準パスに配置
readonly NVIM_CURRENT_BIN="$NVIM_BIN_DIR/nvim"

# パス整合性チェック
check_path_integrity() {
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_warn "Warning: $HOME/.local/bin is not in PATH"
        log_warn "Add to your shell profile: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# 依存関係自動インストール
install_build_dependencies() {
    log_info "Checking and installing build dependencies..."
    
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        "linux")
            install_linux_dependencies
            ;;
        "macos")
            install_macos_dependencies
            ;;
        *)
            log_warn "Automatic dependency installation not supported for platform: $platform"
            log_warn "Please install dependencies manually:"
            log_warn "  git, cmake, make, ninja, gcc, g++, pkg-config, gettext, libtool, autoconf, automake, unzip, curl"
            return 1
            ;;
    esac
}

install_linux_dependencies() {
    log_info "Detecting Linux distribution..."
    
    local packages=()
    local install_cmd=""
    
    if command -v apt &>/dev/null; then
        # Ubuntu/Debian系
        packages=("${REQUIRED_PACKAGES_UBUNTU[@]}")
        install_cmd="sudo apt update && sudo apt install -y"
        log_info "Detected Ubuntu/Debian system"
    elif command -v dnf &>/dev/null; then
        # Fedora系
        packages=("${REQUIRED_PACKAGES_FEDORA[@]}")
        install_cmd="sudo dnf install -y"
        log_info "Detected Fedora system"
    elif command -v yum &>/dev/null; then
        # CentOS/RHEL系
        packages=("${REQUIRED_PACKAGES_FEDORA[@]}")
        install_cmd="sudo yum install -y"
        log_info "Detected CentOS/RHEL system"
    elif command -v pacman &>/dev/null; then
        # Arch Linux系
        packages=("${REQUIRED_PACKAGES_ARCH[@]}")
        install_cmd="sudo pacman -S --needed --noconfirm"
        log_info "Detected Arch Linux system"
    else
        log_error "Unsupported Linux distribution"
        log_warn "Please install dependencies manually"
        return 1
    fi
    
    # 既にインストールされているパッケージをチェック
    local missing_packages=()
    for package in "${packages[@]}"; do
        if ! check_package_installed "$package"; then
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        log_success "All build dependencies are already installed"
        return 0
    fi
    
    log_info "Missing packages: ${missing_packages[*]}"
    log_info "Installing with: $install_cmd ${missing_packages[*]}"
    
    # 非対話的環境では自動でインストール
    if [[ -t 0 ]]; then
        read -p "Install missing dependencies? [Y/n]: " -r
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            log_info "Dependency installation skipped by user"
            return 1
        fi
    else
        log_info "Non-interactive environment detected, installing automatically"
    fi
    
    # パッケージインストール実行
    if eval "$install_cmd ${missing_packages[*]}"; then
        log_success "Dependencies installed successfully"
        return 0
    else
        log_error "Failed to install dependencies"
        return 1
    fi
}

install_macos_dependencies() {
    log_info "Installing dependencies for macOS..."
    
    # Xcodeコマンドラインツールのチェック
    if ! xcode-select -p &>/dev/null; then
        log_info "Xcode command line tools not found. Installing..."
        if [[ -t 0 ]]; then
            read -p "Install Xcode command line tools? This is required. [Y/n]: " -r
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                log_error "Xcode command line tools are required for building"
                return 1
            fi
        fi
        
        log_info "Installing Xcode command line tools..."
        xcode-select --install
        
        log_info "Waiting for Xcode command line tools installation to complete..."
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        log_success "Xcode command line tools installed"
    fi
    
    # Homebrewの確認とインストール
    if ! command -v brew &>/dev/null; then
        log_info "Homebrew not found. Installing Homebrew..."
        
        if [[ -t 0 ]]; then
            read -p "Install Homebrew? This is required for managing dependencies. [Y/n]: " -r
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                log_error "Homebrew is required for dependency management on macOS"
                return 1
            fi
        else
            log_info "Non-interactive environment detected, installing Homebrew automatically"
        fi
        
        # Homebrewインストール
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            log_success "Homebrew installed successfully"
            
            # PATHにHomebrewを追加（Apple Silicon Mac対応）
            if [[ -x "/opt/homebrew/bin/brew" ]]; then
                export PATH="/opt/homebrew/bin:$PATH"
                log_info "Added /opt/homebrew/bin to PATH"
            elif [[ -x "/usr/local/bin/brew" ]]; then
                export PATH="/usr/local/bin:$PATH"
                log_info "Added /usr/local/bin to PATH"
            fi
        else
            log_error "Failed to install Homebrew"
            return 1
        fi
    fi
    
    # Homebrewの更新
    log_info "Updating Homebrew..."
    brew update
    
    local homebrew_packages=(
        "git" "cmake" "make" "ninja" "pkg-config" 
        "gettext" "libtool" "autoconf" "automake" "unzip" "curl"
    )
    
    local missing_packages=()
    for package in "${homebrew_packages[@]}"; do
        if ! brew list "$package" &>/dev/null; then
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        log_success "All build dependencies are already installed"
        return 0
    fi
    
    log_info "Installing missing packages: ${missing_packages[*]}"
    if brew install "${missing_packages[@]}"; then
        log_success "Dependencies installed successfully"
        
        # ninjaがninja-buildとしてインストールされている場合の対応
        if command -v ninja-build &>/dev/null && ! command -v ninja &>/dev/null; then
            log_info "Creating ninja symlink for ninja-build"
            local brew_prefix
            brew_prefix=$(brew --prefix)
            ln -sf "$brew_prefix/bin/ninja-build" "$brew_prefix/bin/ninja" 2>/dev/null || true
        fi
        
        return 0
    else
        log_error "Failed to install dependencies"
        return 1
    fi
}

check_package_installed() {
    local package="$1"
    
    if command -v brew &>/dev/null; then
        # macOS Homebrew
        brew list "$package" &>/dev/null
    elif command -v apt &>/dev/null; then
        dpkg -l | grep -q "^ii.*$package"
    elif command -v dnf &>/dev/null; then
        dnf list installed | grep -q "$package"
    elif command -v yum &>/dev/null; then
        yum list installed | grep -q "$package"
    elif command -v pacman &>/dev/null; then
        pacman -Q "$package" &>/dev/null
    else
        # フォールバック: コマンドの存在チェック
        command -v "$package" &>/dev/null
    fi
}

# 設定ディレクトリ
readonly NVIM_UNIFIED_CONFIG="$DOTFILES_DIR/.config/nvim"
readonly NVIM_STABLE_CONFIG="$NVIM_CONFIG_DIR/nvim-stable"
readonly NVIM_NIGHTLY_CONFIG="$NVIM_CONFIG_DIR/nvim-nightly"
readonly NVIM_CURRENT_CONFIG="$NVIM_CONFIG_DIR/nvim"

# HEAD版関連
readonly HEAD_TRACKER_SCRIPT="$DOTFILES_DIR/bin/neovim-head-tracker.sh"
readonly HEAD_AUTO_UPDATER_SCRIPT="$DOTFILES_DIR/bin/neovim-auto-updater.sh"
readonly HEAD_BASE_DIR="$HOME/.local/neovim-head"

# 必要なパッケージ定義
readonly REQUIRED_PACKAGES_UBUNTU=(
    "git" "cmake" "make" "ninja-build" "build-essential" 
    "gcc" "g++" "pkg-config" "gettext" "libtool" 
    "libtool-bin" "autoconf" "automake" "unzip" "curl"
)

readonly REQUIRED_PACKAGES_FEDORA=(
    "git" "cmake" "make" "ninja-build" "gcc" "gcc-c++" 
    "pkgconfig" "gettext" "libtool" "autoconf" "automake" "unzip" "curl"
)

readonly REQUIRED_PACKAGES_ARCH=(
    "git" "cmake" "make" "ninja" "gcc" "pkgconfig" 
    "gettext" "libtool" "autoconf" "automake" "unzip" "curl"
)

# 状態管理
readonly STATE_STABLE="stable"
readonly STATE_NIGHTLY="nightly"
readonly STATE_HEAD="head"
readonly STATE_NONE="none"

# ===== ユーティリティ関数 =====
# 旧状態ファイルからの移行処理
migrate_old_state() {
    local old_state_file="$HOME/.neovim_version_state"
    if [[ -f "$old_state_file" && ! -f "$NVIM_STATE_FILE" ]]; then
        log_info "Migrating from old state file..."
        local old_state
        old_state=$(cat "$old_state_file")
        echo "$old_state" > "$NVIM_STATE_FILE"
        rm -f "$old_state_file"
        log_success "Migrated state from old version"
    fi
}

read_current_state() {
    migrate_old_state
    if [[ -f "$NVIM_STATE_FILE" ]]; then
        cat "$NVIM_STATE_FILE"
    else
        echo "$STATE_NONE"
    fi
}

write_state() {
    local state="$1"
    echo "$state" > "$NVIM_STATE_FILE"
    log_success "State updated to: $state"
}

# ===== インストール検出 =====
detect_installations() {
    local installations=()
    
    # Stable版チェック
    if [[ -x "$NVIM_STABLE_BIN" ]]; then
        installations+=("stable")
    fi
    
    # Nightly版チェック
    if [[ -x "$NVIM_NIGHTLY_BIN" ]]; then
        installations+=("nightly")
    fi
    
    # HEAD版チェック
    if [[ -f "$HEAD_BASE_DIR/installed_version" ]]; then
        installations+=("head")
    fi
    
    # システムワイドインストールチェック
    if command -v nvim &>/dev/null && [[ "$(command -v nvim)" != "$NVIM_CURRENT_BIN" ]]; then
        installations+=("system")
    fi
    
    printf '%s\n' "${installations[@]}"
}

get_version_info() {
    local version_type="$1"
    
    case "$version_type" in
        "stable")
            if [[ -x "$NVIM_STABLE_BIN" ]]; then
                "$NVIM_STABLE_BIN" --version 2>/dev/null | head -1 || echo "Unknown"
            else
                echo "Not installed"
            fi
            ;;
        "nightly")
            if [[ -x "$NVIM_NIGHTLY_BIN" ]]; then
                "$NVIM_NIGHTLY_BIN" --version 2>/dev/null | head -1 || echo "Unknown"
            else
                echo "Not installed"
            fi
            ;;
        "head")
            if [[ -f "$HEAD_BASE_DIR/installed_version" ]]; then
                cat "$HEAD_BASE_DIR/installed_version"
            else
                echo "Not installed"
            fi
            ;;
        "current")
            if [[ -x "$NVIM_CURRENT_BIN" ]]; then
                "$NVIM_CURRENT_BIN" --version 2>/dev/null | head -1 || echo "Unknown"
            else
                echo "Not installed"
            fi
            ;;
        "system")
            if command -v nvim &>/dev/null && [[ "$(command -v nvim)" != "$NVIM_CURRENT_BIN" ]]; then
                nvim --version 2>/dev/null | head -1 || echo "Unknown"
            else
                echo "Not installed"
            fi
            ;;
    esac
}

# ===== クリーンアップ関数 =====
cleanup_conflicting_installations() {
    local target_version="$1"
    log_info "Cleaning up conflicting installations for $target_version..."
    
    case "$target_version" in
        "head")
            # HEAD版をインストールする際は、stable/nightlyバイナリを残し、
            # 現在のnvimシンボリックリンクのみ削除
            if [[ -L "$NVIM_CURRENT_BIN" ]] || [[ -f "$NVIM_CURRENT_BIN" ]]; then
                log_info "Removing current nvim binary/link"
                rm -f "$NVIM_CURRENT_BIN"
            fi
            ;;
        "stable"|"nightly")
            # stable/nightlyをインストールする際は、HEAD版を無効化
            if [[ -f "$HEAD_BASE_DIR/installed_version" ]]; then
                log_warn "HEAD version is installed. It will be overridden by $target_version."
                # HEAD版のバイナリを一時的に退避
                if [[ -x "$NVIM_CURRENT_BIN" ]]; then
                    mv "$NVIM_CURRENT_BIN" "$HEAD_BASE_DIR/nvim-head-backup" 2>/dev/null || true
                fi
            fi
            ;;
    esac
}

# ===== システムワイドNeovim検出・警告 =====
check_system_neovim() {
    local system_nvim_path
    
    # $HOME/.local/bin以外のneovimを検出
    if system_nvim_path=$(command -v nvim 2>/dev/null) && [[ "$system_nvim_path" != "$NVIM_CURRENT_BIN" ]]; then
        log_warn "System-wide Neovim detected: $system_nvim_path"
        log_warn "Version: $(get_version_info system)"
        log_warn ""
        log_warn "This may conflict with managed versions."
        log_warn "Consider:"
        log_warn "  1. Uninstalling system Neovim: sudo apt remove neovim"
        log_warn "  2. Or ensuring $HOME/.local/bin is first in PATH"
        
        # 非対話的環境では自動で継続
        if [[ -t 0 ]]; then
            echo ""
            read -p "Continue anyway? [y/N]: " -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Aborted by user"
                exit 0
            fi
        else
            log_info "Non-interactive environment detected, continuing automatically"
        fi
    fi
}

# ===== HEAD版専用関数 =====
install_head_version() {
    log_info "Installing Neovim HEAD version..."
    
    # ビルド依存関係の自動インストール
    if ! install_build_dependencies; then
        log_error "Failed to install build dependencies"
        log_error "Please install manually and try again"
        exit 1
    fi
    
    # HEAD追跡スクリプトの存在チェック
    if [[ ! -f "$HEAD_TRACKER_SCRIPT" ]]; then
        log_error "HEAD tracker script not found: $HEAD_TRACKER_SCRIPT"
        log_error "Expected location: $HEAD_TRACKER_SCRIPT"
        log_error "Current script directory: $SCRIPT_DIR"
        ls -la "$SCRIPT_DIR/" | grep neovim || true
        exit 1
    fi
    
    # スクリプトに実行権限を付与
    if [[ ! -x "$HEAD_TRACKER_SCRIPT" ]]; then
        log_info "Adding execute permission to HEAD tracker script"
        chmod +x "$HEAD_TRACKER_SCRIPT"
    fi
    
    # システムワイドNeovimチェック
    check_system_neovim
    
    # 競合する設置のクリーンアップ
    cleanup_conflicting_installations "head"
    
    # HEAD版ビルド・インストール
    log_info "Building Neovim from HEAD..."
    if "$HEAD_TRACKER_SCRIPT" build; then
        write_state "$STATE_HEAD"
        setup_unified_config
        log_success "Neovim HEAD version installed successfully"
        
        # バージョン確認
        local version_info
        version_info=$(get_version_info "head")
        log_info "Installed version: $version_info"
    else
        log_error "Failed to install Neovim HEAD version"
        log_error "Check the build log: $HEAD_BASE_DIR/build.log"
        exit 1
    fi
}

switch_to_head() {
    if [[ ! -f "$HEAD_BASE_DIR/installed_version" ]]; then
        log_error "Neovim HEAD version is not installed"
        log_info "Run: make neovim-head-build"
        exit 1
    fi
    
    # 既存のnvimバイナリを削除/置換
    cleanup_conflicting_installations "head"
    
    # HEAD版が $HOME/.local/bin/nvim に既に配置されているはず
    if [[ -x "$NVIM_CURRENT_BIN" ]]; then
        write_state "$STATE_HEAD"
        setup_unified_config
        log_success "Switched to Neovim HEAD version"
    else
        log_error "HEAD version binary not found"
        exit 1
    fi
}

# ===== stable/nightly版管理 =====
install_stable_nightly() {
    local version="$1"
    
    log_info "Installing Neovim $version version..."
    
    # システムワイドNeovimチェック  
    check_system_neovim
    
    # 既存のneovim_installer.shを使用
    local installer_script="$DOTFILES_DIR/bin/apps/neovim_installer.sh"
    if [[ ! -x "$installer_script" ]]; then
        log_error "Neovim installer script not found: $installer_script"
        exit 1
    fi
    
    # 競合する設置のクリーンアップ
    cleanup_conflicting_installations "$version"
    
    # インストール実行
    if "$installer_script" install "$version"; then
        switch_to_version "$version"
        log_success "Neovim $version version installed successfully"
    else
        log_error "Failed to install Neovim $version version"
        exit 1
    fi
}

switch_to_version() {
    local version="$1"
    
    case "$version" in
        "stable")
            if [[ ! -x "$NVIM_STABLE_BIN" ]]; then
                log_error "Neovim stable version is not installed"
                exit 1
            fi
            
            # 既存のnvimを削除
            rm -f "$NVIM_CURRENT_BIN"
            
            # シンボリックリンク作成
            ln -s "$NVIM_STABLE_BIN" "$NVIM_CURRENT_BIN"
            write_state "$STATE_STABLE"
            ;;
        "nightly")
            if [[ ! -x "$NVIM_NIGHTLY_BIN" ]]; then
                log_error "Neovim nightly version is not installed"
                exit 1
            fi
            
            # 既存のnvimを削除
            rm -f "$NVIM_CURRENT_BIN"
            
            # シンボリックリンク作成
            ln -s "$NVIM_NIGHTLY_BIN" "$NVIM_CURRENT_BIN"
            write_state "$STATE_NIGHTLY"
            ;;
        "head")
            switch_to_head
            return
            ;;
        *)
            log_error "Unknown version: $version"
            exit 1
            ;;
    esac
    
    setup_unified_config
    log_success "Switched to Neovim $version version"
}

# ===== 設定管理 =====
setup_unified_config() {
    log_info "Setting up unified configuration..."
    
    # 既存の設定をバックアップ
    if [[ -d "$NVIM_CURRENT_CONFIG" ]] && [[ ! -L "$NVIM_CURRENT_CONFIG" ]]; then
        local backup_dir="$NVIM_CURRENT_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing config to: $backup_dir"
        mv "$NVIM_CURRENT_CONFIG" "$backup_dir"
    fi
    
    # 統合設定へのシンボリックリンク作成
    if [[ -L "$NVIM_CURRENT_CONFIG" ]]; then
        rm -f "$NVIM_CURRENT_CONFIG"
    fi
    
    ln -s "$NVIM_UNIFIED_CONFIG" "$NVIM_CURRENT_CONFIG"
    log_success "Unified configuration linked"
}

# ===== アンインストール =====
uninstall_version() {
    local version="$1"
    
    case "$version" in
        "stable")
            if [[ -x "$NVIM_STABLE_BIN" ]]; then
                rm -f "$NVIM_STABLE_BIN"
                log_success "Removed Neovim stable version"
            fi
            ;;
        "nightly")
            if [[ -x "$NVIM_NIGHTLY_BIN" ]]; then
                rm -f "$NVIM_NIGHTLY_BIN"
                log_success "Removed Neovim nightly version"
            fi
            ;;
        "head")
            if [[ -x "$HEAD_TRACKER_SCRIPT" ]]; then
                "$HEAD_TRACKER_SCRIPT" clean-all
                log_success "Removed Neovim HEAD version"
            fi
            ;;
        "all")
            uninstall_version "stable"
            uninstall_version "nightly"
            uninstall_version "head"
            rm -f "$NVIM_CURRENT_BIN"
            rm -f "$NVIM_STATE_FILE"
            log_success "Removed all Neovim versions"
            ;;
    esac
    
    # 現在のバージョンが削除された場合
    local current_state
    current_state=$(read_current_state)
    if [[ "$current_state" == "$version" ]]; then
        write_state "$STATE_NONE"
        rm -f "$NVIM_CURRENT_BIN"
    fi
}

# ===== ステータス表示 =====
show_status() {
    local current_state
    current_state=$(read_current_state)
    
    echo "=== Neovim Unified Manager Status ==="
    echo ""
    echo "Current version: $current_state"
    echo ""
    
    echo "Available versions:"
    local installations
    mapfile -t installations < <(detect_installations)
    
    for version in stable nightly head system; do
        local status="❌ Not installed"
        local version_info
        
        if printf '%s\n' "${installations[@]}" | grep -q "^$version$"; then
            status="✅ Installed"
            version_info=$(get_version_info "$version")
            status="$status - $version_info"
        fi
        
        if [[ "$version" == "$current_state" ]]; then
            status="$status (ACTIVE)"
        fi
        
        printf "  %-8s: %s\n" "$version" "$status"
    done
    
    echo ""
    echo "Current binary: $(command -v nvim 2>/dev/null || echo 'Not found')"
    
    if [[ -x "$NVIM_CURRENT_BIN" ]]; then
        echo "Current version info:"
        "$NVIM_CURRENT_BIN" --version | head -3
    fi
}

# ===== メイン処理 =====
main() {
    local command="${1:-status}"
    
    case "$command" in
        "install")
            local version="${2:-}"
            if [[ -z "$version" ]]; then
                log_error "Version required. Use: stable, nightly, or head"
                exit 1
            fi
            
            case "$version" in
                "head")
                    install_head_version
                    ;;
                "stable"|"nightly")
                    install_stable_nightly "$version"
                    ;;
                *)
                    log_error "Unknown version: $version"
                    exit 1
                    ;;
            esac
            ;;
        "switch")
            local version="${2:-}"
            if [[ -z "$version" ]]; then
                log_error "Version required. Use: stable, nightly, or head"
                exit 1
            fi
            switch_to_version "$version"
            ;;
        "uninstall")
            local version="${2:-}"
            if [[ -z "$version" ]]; then
                log_error "Version required. Use: stable, nightly, head, or all"
                exit 1
            fi
            uninstall_version "$version"
            ;;
        "status")
            show_status
            ;;
        "update")
            local current_state
            current_state=$(read_current_state)
            case "$current_state" in
                "head")
                    log_info "Updating HEAD version..."
                    "$HEAD_TRACKER_SCRIPT" update
                    ;;
                "stable"|"nightly")
                    log_info "Updating $current_state version..."
                    install_stable_nightly "$current_state"
                    ;;
                *)
                    log_warn "No active version to update"
                    ;;
            esac
            ;;
        "cleanup")
            log_info "Cleaning up broken installations..."
            # TODO: 壊れたインストールの検出・修復
            ;;
        "deps"|"dependencies")
            log_info "Checking build dependencies..."
            install_build_dependencies
            ;;
        *)
            cat << EOF
Neovim Unified Manager

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  install <version>    Install specific version (stable, nightly, head)
  switch <version>     Switch to specific version
  uninstall <version>  Uninstall specific version (stable, nightly, head, all)
  update               Update current version
  status               Show status of all versions (default)
  cleanup              Clean up broken installations
  deps                 Check and install build dependencies

Examples:
  $0 install head      Install and switch to HEAD version
  $0 switch stable     Switch to stable version
  $0 uninstall all     Remove all versions
  $0 status            Show current status
  $0 deps              Install build dependencies
EOF
            exit 1
            ;;
    esac
}

main "$@"