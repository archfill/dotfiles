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
    ".config/nvim"
    ".vimrc"
    ".gvimrc"
    ".ideavimrc"
    ".config/alacritty"
    ".config/wezterm"
    ".config/ghostty"
    ".muttrc"
    ".mutt"
    ".config/aerc"
    ".textlintrc"
    ".tmux/bin"
    ".config/tmux"
    ".config/zsh"
    ".zshenv"
    ".config/sheldon"
    ".mmcp.json"
    ".config/hypr"
    ".config/waybar"
    ".config/swaync"
    ".config/wlogout"
    ".config/scripts"
    ".config/eww"
    ".config/matugen"
    ".config/rofi"
    ".config/ags"
    ".config/lazygit"
)

# 基本設定ファイルのシンボリックリンク作成
log_info "Creating basic configuration symlinks"
create_symlinks_batch "${BASIC_CONFIGS[@]}"

# 特別なパスマッピングが必要な設定ファイル
log_info "Creating special path mapping symlinks"
# tmux設定: .config/tmux/tmux.conf → ~/.tmux.conf
# (.config/tmuxディレクトリ全体がシンボリックリンクされるため、個別の処理は不要)
if [[ -f "${DOTFILES_DIR}/.config/tmux/tmux.conf" ]] && [[ ! -L "${HOME}/.config/tmux" ]]; then
    create_symlink "${DOTFILES_DIR}/.config/tmux/tmux.conf" "${HOME}/.tmux.conf"
fi

# aicommit2設定: .config/aicommit2/config → ~/.aicommit2
if [[ -f "${DOTFILES_DIR}/.config/aicommit2/config" ]]; then
    create_symlink "${DOTFILES_DIR}/.config/aicommit2/config" "${HOME}/.aicommit2"
fi

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

