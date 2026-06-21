#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# DOTFILES_DIRが設定されていない場合は設定
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

source "${DOTFILES_DIR}/bin/lib/common.sh"
source "${DOTFILES_DIR}/bin/lib/config_loader.sh"
source "${DOTFILES_DIR}/bin/lib/symlink_manager.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting dotfiles symlink creation"

# 設定ファイルを読み込み
load_config

# 基本設定ファイルの一覧
BASIC_CONFIGS=(
    # ".config/git/config" は home-manager (nix/modules/common.nix) で XDG 管理
    # ".config/nvim" は home-manager (nix/modules/common.nix) で管理
    # ".vimrc"     は home-manager (nix/modules/common.nix) で管理
    # ".gvimrc"    は home-manager (nix/modules/common.nix) で管理
    # ".ideavimrc" は home-manager (nix/modules/common.nix) で管理
    # ".config/alacritty" は home-manager (nix/modules/common.nix) で管理
    # ".config/wezterm"   は home-manager (nix/modules/common.nix) で管理
    # ".config/ghostty"   は home-manager (nix/modules/common.nix) で管理
    # ".muttrc"      は home-manager (nix/modules/common.nix) で管理
    # ".mutt"        は home-manager (nix/modules/common.nix) で管理
    # ".config/aerc" は home-manager (nix/modules/common.nix) で管理
    # ".textlintrc"  は不要のため削除済み
    # ".tmux/bin"    は home-manager (nix/modules/common.nix) で管理
    # ".config/tmux" は home-manager (programs.tmux + mkOutOfStoreSymlink) で管理
    # ".config/zsh" は home-manager (nix/modules/common.nix) で管理
    # ".zshenv"     は home-manager (nix/modules/common.nix) で管理
    # ".config/sheldon" は home-manager (nix/modules/common.nix) で管理
    ".mmcp.json"
    ".config/hypr"
    ".config/wlogout"
    # ".config/scripts" は dotfiles 内に shell 拡張用の置き場として残すが
    # ホームへの symlink は作らない (呼び出し時はフルパスで参照する方針)
    ".config/eww"
    ".config/matugen"
    ".config/rofi"
    # ".config/lazygit" は home-manager (nix/modules/common.nix) で管理
)

# 基本設定ファイルのシンボリックリンク作成
log_info "Creating basic configuration symlinks"
create_symlinks_batch "${BASIC_CONFIGS[@]}"

# 特別なパスマッピングが必要な設定ファイル
# - ~/.tmux.conf: tmux 1.6+ が ~/.config/tmux/tmux.conf を自動参照するため不要
# - ~/.aicommit2: home-manager (nix/modules/common.nix) で管理
# - ~/.tmux ディレクトリ: home-manager (nix/modules/common.nix) が
#   ~/.tmux/bin を symlink する際に自動作成するため明示作成不要

# zshの既存ファイル削除（バックアップしない）
log_info "Cleaning up existing zsh files"
if [[ -f "${HOME}/.zshrc" ]]; then
    log_info "Removing existing .zshrc"
    rm -f "${HOME}/.zshrc"
fi
if [[ -e "${HOME}/.zsh" ]]; then
    log_info "Removing existing .zsh directory"
    rm -rf "${HOME}/.zsh"
fi

# プラットフォーム固有のシンボリックリンク作成
create_platform_specific_symlinks

log_success "All symlinks created successfully"
