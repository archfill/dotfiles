#!/usr/bin/env bash
# neovim-macos.sh
# Neovim installer for macOS using Homebrew
# Supports stable and nightly versions

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# ===== プラットフォームチェック =====
check_platform() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        log_error "This script is for macOS only"
        log_info "For Linux, Neovim is managed by Nix in this repository."
        exit 1
    fi
}

# ===== Homebrewチェック =====
check_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew is not installed"
        log_info "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    return 0
}

# ===== インストール済みバージョンの取得 =====
get_installed_version() {
    if ! brew list neovim >/dev/null 2>&1; then
        echo "none"
        return 1
    fi

    local version_output
    version_output=$(brew list --versions neovim 2>/dev/null | head -1)

    if [[ "$version_output" == *"HEAD"* ]]; then
        echo "nightly"
    else
        echo "stable"
    fi
}

# ===== バージョン情報の表示 =====
show_version_info() {
    if command -v nvim >/dev/null 2>&1; then
        nvim --version | head -3
    else
        echo "Neovim is not installed or not in PATH"
    fi
}

# ===== インストール =====
install_neovim() {
    local version="$1"

    check_platform

    if ! check_homebrew; then
        return 1
    fi

    # 既存インストールをチェック
    local current_version
    current_version=$(get_installed_version) || true

    if [[ "$current_version" != "none" ]]; then
        if [[ "$current_version" == "$version" ]]; then
            log_warning "Neovim $version is already installed"
            log_info "To reinstall, run: make neovim-uninstall VERSION=$version && make neovim-install VERSION=$version"
            log_info "To update, run: make neovim-update"
            return 0
        else
            log_warning "Neovim $current_version is currently installed"
            log_info "To switch to $version, first uninstall the current version:"
            log_info "  make neovim-uninstall VERSION=$current_version"
            return 1
        fi
    fi

    log_info "Installing Neovim $version via Homebrew..."

    if [[ "$version" == "stable" ]]; then
        if brew install neovim; then
            log_success "Neovim stable installed successfully"
            show_version_info
            return 0
        else
            log_error "Failed to install Neovim stable"
            return 1
        fi
    elif [[ "$version" == "nightly" ]]; then
        if brew install neovim --HEAD; then
            log_success "Neovim nightly installed successfully"
            show_version_info
            return 0
        else
            log_error "Failed to install Neovim nightly"
            return 1
        fi
    else
        log_error "Invalid version: $version (use stable or nightly)"
        return 1
    fi
}

# ===== アンインストール =====
uninstall_neovim() {
    local version="$1"

    check_platform

    if ! check_homebrew; then
        return 1
    fi

    local current_version
    current_version=$(get_installed_version) || true

    if [[ "$current_version" == "none" ]]; then
        log_info "Neovim is not installed"
        return 0
    fi

    # version指定がある場合は、現在のバージョンと一致するかチェック
    if [[ "$version" != "all" ]]; then
        if [[ "$current_version" != "$version" ]]; then
            log_warning "Neovim $version is not installed (current: $current_version)"
            log_info "To uninstall the current version, run: make neovim-uninstall VERSION=$current_version"
            return 1
        fi
    fi

    log_info "Uninstalling Neovim $current_version..."

    if brew uninstall neovim; then
        log_success "Neovim uninstalled successfully"
        return 0
    else
        log_error "Failed to uninstall Neovim"
        return 1
    fi
}

# ===== バージョン確認 =====
check_version() {
    local version="$1"

    check_platform

    if ! check_homebrew; then
        return 1
    fi

    local current_version
    current_version=$(get_installed_version) || true

    if [[ "$current_version" == "none" ]]; then
        log_info "Neovim is not installed"
        return 1
    fi

    if [[ "$version" == "$current_version" ]]; then
        log_info "Neovim $version is installed:"
        show_version_info
        return 0
    else
        log_info "Neovim $current_version is installed (not $version)"
        return 1
    fi
}

# ===== ステータス表示 =====
show_status() {
    check_platform

    echo "=== Neovim Status (Homebrew) ==="
    echo ""

    if ! check_homebrew; then
        echo "Homebrew is not installed"
        return 1
    fi

    local current_version
    current_version=$(get_installed_version) || true

    if [[ "$current_version" == "none" ]]; then
        echo "Status: Not installed"
        echo ""
        echo "Install commands:"
        echo "  make neovim-install VERSION=stable"
        echo "  make neovim-install VERSION=nightly"
    else
        echo "Status: Installed ($current_version)"
        echo ""
        show_version_info
        echo ""
        echo "Available commands:"
        echo "  make neovim-update              # Update current version"
        echo "  make neovim-uninstall VERSION=$current_version  # Uninstall"

        local other_version="stable"
        if [[ "$current_version" == "stable" ]]; then
            other_version="nightly"
        fi
        echo "  make neovim-uninstall VERSION=$current_version && make neovim-install VERSION=$other_version  # Switch to $other_version"
    fi
}

# ===== バージョン切り替え =====
set_default_version() {
    local version="$1"

    check_platform

    if ! check_homebrew; then
        return 1
    fi

    local current_version
    current_version=$(get_installed_version) || true

    if [[ "$current_version" == "none" ]]; then
        log_info "Neovim is not installed. Installing $version..."
        install_neovim "$version"
        return $?
    fi

    if [[ "$current_version" == "$version" ]]; then
        log_success "Neovim $version is already active"
        show_version_info
        return 0
    fi

    # 異なるバージョンの場合、アンインストール→インストール
    log_info "Switching from $current_version to $version..."
    log_info ""

    # アンインストール
    log_info "Step 1: Uninstalling Neovim $current_version..."
    if ! uninstall_neovim "$current_version"; then
        log_error "Failed to uninstall Neovim $current_version"
        return 1
    fi

    log_info ""

    # インストール
    log_info "Step 2: Installing Neovim $version..."
    if ! install_neovim "$version"; then
        log_error "Failed to install Neovim $version"
        return 1
    fi

    log_success "Successfully switched to Neovim $version"
    return 0
}

# ===== アップデート =====
update_neovim() {
    check_platform

    if ! check_homebrew; then
        return 1
    fi

    local current_version
    current_version=$(get_installed_version) || true

    if [[ "$current_version" == "none" ]]; then
        log_error "Neovim is not installed"
        return 1
    fi

    log_info "Updating Neovim $current_version..."

    if [[ "$current_version" == "nightly" ]]; then
        # nightly版は--fetch-HEADでアップデート
        if brew upgrade neovim --fetch-HEAD; then
            log_success "Neovim nightly updated successfully"
            show_version_info
            return 0
        else
            # 既に最新の場合もあるので、エラーではない
            log_info "Neovim nightly is already up-to-date"
            show_version_info
            return 0
        fi
    else
        # stable版は通常のupgrade
        if brew upgrade neovim; then
            log_success "Neovim stable updated successfully"
            show_version_info
            return 0
        else
            # 既に最新の場合もあるので、エラーではない
            log_info "Neovim is already up-to-date"
            show_version_info
            return 0
        fi
    fi
}

# ===== メイン処理 =====
main() {
    local command="${1:-}"
    local version="${2:-}"

    case "$command" in
        "install")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable or nightly"
                exit 1
            fi

            if [[ "$version" != "stable" && "$version" != "nightly" ]]; then
                log_error "Invalid version: $version (use stable or nightly)"
                exit 1
            fi

            install_neovim "$version"
            ;;
        "uninstall")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable, nightly, or all"
                exit 1
            fi

            if [[ "$version" != "stable" && "$version" != "nightly" && "$version" != "all" ]]; then
                log_error "Invalid version: $version (use stable, nightly, or all)"
                exit 1
            fi

            uninstall_neovim "$version"
            ;;
        "check")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable or nightly"
                exit 1
            fi

            check_version "$version"
            ;;
        "status")
            show_status
            ;;
        "default")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable or nightly"
                exit 1
            fi

            if [[ "$version" != "stable" && "$version" != "nightly" ]]; then
                log_error "Invalid version: $version (use stable or nightly)"
                exit 1
            fi

            set_default_version "$version"
            ;;
        "update")
            update_neovim
            ;;
        *)
            cat << 'EOF'
Neovim Installer for macOS (Homebrew)

Usage: neovim-macos.sh [COMMAND] [VERSION]

Commands:
  install <version>    Install Neovim (stable or nightly)
  uninstall <version>  Uninstall Neovim (stable, nightly, or all)
  check <version>      Check installed version
  default <version>    Set default Neovim version (requires reinstall)
  status               Show installation status
  update               Update current Neovim version

Examples:
  neovim-macos.sh install stable
  neovim-macos.sh install nightly
  neovim-macos.sh status
  neovim-macos.sh update
  neovim-macos.sh uninstall all

Makefile Usage:
  make neovim-install VERSION=stable
  make neovim-install VERSION=nightly
  make neovim-status
  make neovim-update
  make neovim-uninstall VERSION=all

Note: Homebrew can only have one version installed at a time.
      To switch versions, uninstall the current version first.
EOF
            exit 1
            ;;
    esac
}

main "$@"
