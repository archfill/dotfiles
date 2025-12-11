#!/usr/bin/env bash

# neovim-unified-manager.sh
# Neovim統合管理ラッパースクリプト
# プラットフォームに応じて適切なNeovimインストーラーを呼び出します
#
# Linux: bin/appimages/neovim.sh (AppImage)
# macOS: bin/installers/neovim.sh (tar.gz)

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# =============================================================================
# プラットフォーム判定とスクリプト選択
# =============================================================================

get_neovim_script() {
    local platform
    platform=$(uname -s)

    case "$platform" in
        Linux)
            echo "$DOTFILES_DIR/bin/install-methods/appimage/neovim.sh"
            ;;
        Darwin)
            echo "$DOTFILES_DIR/bin/install-methods/binary/neovim-macos.sh"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            return 1
            ;;
    esac
}

# =============================================================================
# コマンドマッピング
# =============================================================================

# Makefileコマンドを各スクリプトのコマンドにマッピング
map_command() {
    local cmd="$1"
    local version="$2"

    case "$cmd" in
        install)
            # make neovim-install VERSION=stable/nightly
            echo "install $version"
            ;;
        switch)
            # make neovim-switch VERSION=stable/nightly
            # -> default コマンドに変換
            echo "default $version"
            ;;
        uninstall)
            # make neovim-uninstall VERSION=stable/nightly/all
            echo "uninstall $version"
            ;;
        status)
            # make neovim-status
            echo "status"
            ;;
        update)
            # make neovim-update
            # 現在アクティブなバージョンを更新（statusから判定）
            echo "update"
            ;;
        *)
            log_error "Unknown command: $cmd"
            return 1
            ;;
    esac
}

# =============================================================================
# fzfでバージョン選択
# =============================================================================

select_version_with_fzf() {
    local command="$1"
    local options

    case "$command" in
        install|switch)
            options="stable\nnightly"
            ;;
        uninstall)
            options="stable\nnightly\nall"
            ;;
        *)
            return 1
            ;;
    esac

    if command -v fzf >/dev/null 2>&1; then
        echo -e "$options" | fzf --prompt="Select Neovim version to $command: " --height=10 --reverse
    else
        return 1
    fi
}

# =============================================================================
# メイン処理
# =============================================================================

main() {
    local command="${1:-status}"
    local version="${2:-}"

    # バージョンが必要なコマンドでバージョン未指定の場合、fzfで選択
    if [[ -z "$version" ]]; then
        case "$command" in
            install|switch|uninstall)
                version=$(select_version_with_fzf "$command")
                if [[ -z "$version" ]]; then
                    log_info "Cancelled."
                    exit 0
                fi
                ;;
            status|update)
                # これらのコマンドはバージョン不要
                ;;
            *)
                version="stable"
                ;;
        esac
    fi

    # プラットフォーム別スクリプトを取得
    local script
    script=$(get_neovim_script) || exit 1

    if [[ ! -x "$script" ]]; then
        log_error "Neovim script not found or not executable: $script"
        exit 1
    fi

    # コマンドマッピング
    local mapped_cmd
    mapped_cmd=$(map_command "$command" "$version")
    local map_result=$?

    if [[ $map_result -eq 1 ]]; then
        # エラー
        show_usage
        exit 1
    fi

    # 適切なスクリプトを実行
    log_info "Platform: $(uname -s)"
    log_info "Using script: $(basename "$script")"
    log_info "Command: $mapped_cmd"
    log_info ""

    # shellcheck disable=SC2086
    exec "$script" $mapped_cmd
}

# =============================================================================
# ヘルプ表示
# =============================================================================

show_usage() {
    cat << 'EOF'
Neovim Unified Manager - Platform-aware wrapper

This script automatically selects the appropriate Neovim installer:
  • Linux:  bin/appimages/neovim.sh (AppImage)
  • macOS:  bin/installers/neovim.sh (tar.gz)

Usage: neovim-unified-manager.sh <command> [version]

Commands:
  install [stable|nightly]   Install Neovim (default: stable)
  switch [stable|nightly]    Switch active Neovim version
  uninstall [stable|nightly|all]  Uninstall Neovim
  status                     Show installation status
  update                     Update current Neovim version

Examples:
  neovim-unified-manager.sh install stable
  neovim-unified-manager.sh install nightly
  neovim-unified-manager.sh switch nightly
  neovim-unified-manager.sh status
  neovim-unified-manager.sh update
  neovim-unified-manager.sh uninstall all

Makefile Usage:
  make neovim-install VERSION=stable
  make neovim-switch VERSION=nightly
  make neovim-status
  make neovim-update
  make neovim-uninstall VERSION=all

Platform-specific Scripts:
  Linux:  $DOTFILES_DIR/bin/appimages/neovim.sh
  macOS:  $DOTFILES_DIR/bin/installers/neovim.sh
EOF
}

# メイン処理実行
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

main "$@"
