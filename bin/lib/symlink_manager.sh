#!/usr/bin/env bash

# シンボリックリンク管理ライブラリ

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/config_loader.sh"

# 統一されたシンボリックリンク作成関数
# 使用方法:
#   create_symlink "source_path" "target_path"
#   create_symlink_from_dotfiles ".config/nvim"  # HOME/dotfiles/.config/nvim -> HOME/.config/nvim
create_symlink() {
    local source_path="$1"
    local target_path="${2:-}"
    local backup_existing="${3:-true}"
    
    # 引数の検証
    if [[ -z "$source_path" ]]; then
        log_error "Source path is required"
        return 1
    fi
    
    # デフォルトのターゲットパス設定
    if [[ -z "$target_path" ]]; then
        target_path="${HOME}/${source_path}"
        source_path="${DOTFILES_DIR:-$HOME/dotfiles}/${source_path}"
    fi
    
    # ソースパスの存在確認
    if [[ ! -e "$source_path" ]]; then
        log_error "Source path does not exist: $source_path"
        return 1
    fi
    
    # ターゲットディレクトリの作成
    local target_dir
    target_dir="$(dirname "$target_path")"
    if [[ ! -d "$target_dir" ]]; then
        log_info "Creating target directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # 既存ファイルの処理
    if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
        if [[ "$backup_existing" == "true" ]]; then
            backup_existing_file "$target_path"
        else
            log_info "Removing existing: $target_path"
            rm -rf "$target_path"
        fi
    fi
    
    # シンボリックリンクの作成
    log_info "Creating symlink: $target_path -> $source_path"
    ln -snf "$source_path" "$target_path"
    
    # 作成確認
    if [[ -L "$target_path" ]]; then
        log_success "Symlink created successfully: $target_path"
        return 0
    else
        log_error "Failed to create symlink: $target_path"
        return 1
    fi
}

# dotfilesディレクトリからのシンボリックリンク作成（簡易版）
create_symlink_from_dotfiles() {
    local relative_path="$1"
    local backup_existing="${2:-true}"
    
    # DOTFILES_DIRが設定されていない場合のみload_config
    if [[ -z "${DOTFILES_DIR:-}" ]]; then
        load_config  # DOTFILES_DIRを取得
    fi
    
    local source_path="${DOTFILES_DIR}/${relative_path}"
    local target_path="${HOME}/${relative_path}"
    
    create_symlink "$source_path" "$target_path" "$backup_existing"
}

# 既存ファイルのバックアップ
backup_existing_file() {
    local file_path="$1"
    local backup_dir="${HOME}/.dotfiles_backup"
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    
    # バックアップディレクトリの作成
    mkdir -p "$backup_dir"
    
    # ファイル名の取得
    local filename
    filename="$(basename "$file_path")"
    local backup_path="${backup_dir}/${filename}.${timestamp}"
    
    log_info "Backing up existing file: $file_path -> $backup_path"
    
    if [[ -L "$file_path" ]]; then
        # シンボリックリンクの場合は削除のみ
        rm "$file_path"
        log_info "Removed existing symlink: $file_path"
    else
        # 通常のファイル/ディレクトリの場合はバックアップ
        mv "$file_path" "$backup_path"
        log_info "Moved to backup: $backup_path"
    fi
}

# バッチシンボリックリンク作成
# 設定ファイルリストからまとめてシンボリックリンクを作成
create_symlinks_batch() {
    local config_list=("$@")
    local failed_count=0
    local success_count=0
    
    log_info "Creating ${#config_list[@]} symlinks..."
    
    for config_path in "${config_list[@]}"; do
        if create_symlink_from_dotfiles "$config_path"; then
            success_count=$((success_count + 1))
        else
            failed_count=$((failed_count + 1))
        fi
    done
    
    log_info "Symlink creation completed: $success_count success, $failed_count failed"
    
    if [[ $failed_count -gt 0 ]]; then
        return 1
    fi
    return 0
}

# シンボリックリンクの検証
verify_symlink() {
    local target_path="$1"
    
    if [[ ! -L "$target_path" ]]; then
        log_error "Not a symlink: $target_path"
        return 1
    fi
    
    local source_path
    source_path="$(readlink "$target_path")"
    
    if [[ ! -e "$source_path" ]]; then
        log_error "Broken symlink: $target_path -> $source_path"
        return 1
    fi
    
    log_info "Valid symlink: $target_path -> $source_path"
    return 0
}

# シンボリックリンクの削除
remove_symlink() {
    local target_path="$1"
    
    if [[ ! -L "$target_path" ]]; then
        log_warning "Not a symlink, skipping: $target_path"
        return 0
    fi
    
    log_info "Removing symlink: $target_path"
    rm "$target_path"
    
    if [[ ! -e "$target_path" ]]; then
        log_success "Symlink removed: $target_path"
        return 0
    else
        log_error "Failed to remove symlink: $target_path"
        return 1
    fi
}

# プラットフォーム固有のシンボリックリンク作成
create_platform_specific_symlinks() {
    local platform
    platform="$(detect_platform)"
    
    log_info "Creating platform-specific symlinks for: $platform"
    
    case "$platform" in
        "macos")
            create_macos_symlinks
            ;;
        "linux")
            create_linux_symlinks
            ;;
        "cygwin")
            create_cygwin_symlinks
            ;;
        *)
            log_warning "Unknown platform: $platform"
            ;;
    esac
}

# macOS固有のシンボリックリンク
create_macos_symlinks() {
    local macos_configs=(
        ".config/karabiner"
        ".config/yabai"
        ".config/skhd"
    )
    
    for config in "${macos_configs[@]}"; do
        if [[ -d "${DOTFILES_DIR}/${config}" ]]; then
            create_symlink_from_dotfiles "$config"
        fi
    done
}

# Linux固有のシンボリックリンク
create_linux_symlinks() {
    local linux_configs=(
        ".config/i3"
        ".config/polybar"
        ".xinitrc"
        ".Xresources"
    )
    
    for config in "${linux_configs[@]}"; do
        if [[ -e "${DOTFILES_DIR}/${config}" ]]; then
            create_symlink_from_dotfiles "$config"
        fi
    done
}

# Cygwin固有のシンボリックリンク
create_cygwin_symlinks() {
    log_info "No specific symlinks required for Cygwin"
}