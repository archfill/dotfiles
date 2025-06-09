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
    ".config/nvim"
    ".vimrc"
    ".gvimrc"
    ".ideavimrc"
    ".config/alacritty"
    ".config/kitty"
    ".config/wezterm"
    ".config/direnv"
    ".muttrc"
    ".mutt"
    ".textlintrc"
    ".tmux/bin"
    ".tmux.conf"
    ".tmux-powerlinerc"
    ".config/zsh"
    ".zshenv"
)

# 基本設定ファイルのシンボリックリンク作成
log_info "Creating basic configuration symlinks"
create_symlinks_batch "${BASIC_CONFIGS[@]}"

# tmuxディレクトリの作成（必要な場合）
TMUX_DIR="${HOME}/.tmux"
if [[ ! -d "$TMUX_DIR" ]]; then
    log_info "Creating tmux directory: $TMUX_DIR"
    mkdir -p "$TMUX_DIR"
fi

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

