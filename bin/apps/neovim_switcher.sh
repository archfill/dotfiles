#!/usr/bin/env bash

# Neovim Stable/Nightly Switcher
# このスクリプトはNeovimのstable版とnightly版を切り替える機能を提供します

set -euo pipefail

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../lib/common.sh
source "$DOTFILES_DIR/bin/lib/common.sh"
# shellcheck source=../lib/config_loader.sh
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# 定数定義
readonly NVIM_CONFIG_DIR="$HOME/.config"
readonly NVIM_STABLE_CONFIG="$NVIM_CONFIG_DIR/nvim-stable"
readonly NVIM_NIGHTLY_CONFIG="$NVIM_CONFIG_DIR/nvim-nightly"
readonly NVIM_CURRENT_LINK="$NVIM_CONFIG_DIR/nvim-current"
readonly NVIM_STATE_FILE="$HOME/.neovim_version_state"

# バイナリ関連の定数
readonly NVIM_BIN_DIR="$HOME/.local/bin"
readonly NVIM_STABLE_BIN="$NVIM_BIN_DIR/nvim-stable"
readonly NVIM_NIGHTLY_BIN="$NVIM_BIN_DIR/nvim-nightly" 
readonly NVIM_CURRENT_BIN="$NVIM_BIN_DIR/nvim"

# 使用方法を表示
show_usage() {
    cat << EOF
Neovim Stable/Nightly Switcher

使用方法:
    $(basename "$0") [COMMAND]

コマンド:
    setup       初期セットアップを実行
    stable      stable版に切り替え
    nightly     nightly版に切り替え
    toggle      stable⇔nightlyの切り替え
    update      現在のバージョンをアップデート
    update-all  両方のバージョンをアップデート
    status      現在の状態を表示
    list        利用可能なバージョンを表示
    help        このヘルプを表示

クイックコマンド:
    s           stable版に切り替え (短縮形)
    n           nightly版に切り替え (短縮形)
    t           toggle切り替え (短縮形)
    u           現在のバージョンをアップデート (短縮形)

例:
    $(basename "$0") setup
    $(basename "$0") stable
    $(basename "$0") nightly
    $(basename "$0") toggle
    $(basename "$0") update
    $(basename "$0") s        # stable版に切り替え
    $(basename "$0") n        # nightly版に切り替え
    $(basename "$0") t        # toggle切り替え
    $(basename "$0") u        # アップデート
EOF
}

# 現在の状態を取得
get_current_version() {
    if [[ -f "$NVIM_STATE_FILE" ]]; then
        cat "$NVIM_STATE_FILE"
    else
        echo "unknown"
    fi
}

# 状態を保存
save_current_version() {
    local version="$1"
    echo "$version" > "$NVIM_STATE_FILE"
}

# Neovimがインストールされているかチェック
check_neovim_installed() {
    local version="$1"
    case "$version" in
        "stable")
            if [[ -f "$NVIM_STABLE_BIN" ]] || [[ -f "$NVIM_BIN_DIR/nvim" ]]; then
                return 0
            fi
            ;;
        "nightly")
            if [[ -f "$NVIM_NIGHTLY_BIN" ]]; then
                return 0
            fi
            ;;
    esac
    return 1
}

# バイナリファイルの整理
organize_binaries() {
    log_info "Neovimバイナリファイルを整理しています..."
    
    # 現在のnvimがstable版の場合、nvim-stableとして保存
    if [[ -f "$NVIM_CURRENT_BIN" ]] && [[ ! -f "$NVIM_STABLE_BIN" ]]; then
        log_info "現在のnvimをstable版として設定しています..."
        cp "$NVIM_CURRENT_BIN" "$NVIM_STABLE_BIN"
    fi
    
    # nvim.bakがある場合の処理
    if [[ -f "$NVIM_BIN_DIR/nvim.bak" ]]; then
        if [[ ! -f "$NVIM_STABLE_BIN" ]]; then
            log_info "バックアップファイルをstable版として復元しています..."
            mv "$NVIM_BIN_DIR/nvim.bak" "$NVIM_STABLE_BIN"
        else
            log_info "不要なバックアップファイルを削除しています..."
            rm "$NVIM_BIN_DIR/nvim.bak"
        fi
    fi
    
    log_success "バイナリファイルの整理が完了しました"
}

# バイナリの切り替え
switch_binary() {
    local target_version="$1"
    local target_binary=""
    
    case "$target_version" in
        "stable")
            target_binary="$NVIM_STABLE_BIN"
            ;;
        "nightly")
            target_binary="$NVIM_NIGHTLY_BIN"
            ;;
        *)
            log_error "無効なバージョンです: $target_version"
            return 1
            ;;
    esac
    
    # ターゲットバイナリが存在するかチェック
    if [[ ! -f "$target_binary" ]]; then
        log_error "${target_version}版のバイナリが見つかりません: $target_binary"
        log_info "先に '$(basename "$0") install $target_version' を実行してください"
        return 1
    fi
    
    # 現在のnvimリンクを削除
    if [[ -L "$NVIM_CURRENT_BIN" ]]; then
        rm "$NVIM_CURRENT_BIN"
    elif [[ -f "$NVIM_CURRENT_BIN" ]]; then
        # 通常ファイルの場合は一旦退避
        if [[ ! -f "$NVIM_STABLE_BIN" ]]; then
            mv "$NVIM_CURRENT_BIN" "$NVIM_STABLE_BIN"
        else
            rm "$NVIM_CURRENT_BIN"
        fi
    fi
    
    # 新しいシンボリックリンクを作成
    ln -sf "$target_binary" "$NVIM_CURRENT_BIN"
    
    log_success "Neovimバイナリを${target_version}版に切り替えました"
    log_info "バイナリパス: $target_binary"
}

# 設定ディレクトリの初期化
init_config_directories() {
    log_info "Neovim設定ディレクトリを初期化しています..."
    
    # dotfilesリポジトリ内の分離された設定を使用
    local dotfiles_stable_config="$DOTFILES_DIR/.config/nvim-stable"
    local dotfiles_nightly_config="$DOTFILES_DIR/.config/nvim-nightly"
    
    # dotfiles内の設定が存在することを確認
    if [[ ! -d "$dotfiles_stable_config" ]]; then
        log_error "dotfiles内のstable版設定が見つかりません: $dotfiles_stable_config"
        log_info "フォールバック: 既存のnvim設定を使用します"
        dotfiles_stable_config="$DOTFILES_DIR/.config/nvim"
    fi
    
    if [[ ! -d "$dotfiles_nightly_config" ]]; then
        log_error "dotfiles内のnightly版設定が見つかりません: $dotfiles_nightly_config"
        log_info "フォールバック: stable版設定をベースに作成します"
        dotfiles_nightly_config="$dotfiles_stable_config"
    fi
    
    # 既存のnvim設定をstableとして保存（既存ユーザー向け互換性）
    if [[ -d "$NVIM_CONFIG_DIR/nvim" ]] && [[ ! -L "$NVIM_CONFIG_DIR/nvim" ]] && [[ ! -d "$NVIM_STABLE_CONFIG" ]]; then
        log_info "既存のNeovim設定をstable版として保存しています..."
        mv "$NVIM_CONFIG_DIR/nvim" "$NVIM_STABLE_CONFIG"
    fi
    
    # stable版設定ディレクトリの作成
    if [[ ! -d "$NVIM_STABLE_CONFIG" ]]; then
        log_info "dotfilesからstable版設定をコピーしています..."
        cp -r "$dotfiles_stable_config" "$NVIM_STABLE_CONFIG"
        log_success "stable版設定ディレクトリを作成しました: $NVIM_STABLE_CONFIG"
    else
        log_info "stable版設定は既に存在します: $NVIM_STABLE_CONFIG"
    fi
    
    # nightly版設定ディレクトリの作成
    if [[ ! -d "$NVIM_NIGHTLY_CONFIG" ]]; then
        log_info "dotfilesからnightly版設定をコピーしています..."
        cp -r "$dotfiles_nightly_config" "$NVIM_NIGHTLY_CONFIG"
        log_success "nightly版設定ディレクトリを作成しました: $NVIM_NIGHTLY_CONFIG"
    else
        log_info "nightly版設定は既に存在します: $NVIM_NIGHTLY_CONFIG"
    fi
}

# 設定とバイナリを切り替え
switch_config() {
    local target_version="$1"
    local target_config=""
    
    case "$target_version" in
        "stable")
            target_config="$NVIM_STABLE_CONFIG"
            ;;
        "nightly")
            target_config="$NVIM_NIGHTLY_CONFIG"
            ;;
        *)
            log_error "無効なバージョンです: $target_version"
            return 1
            ;;
    esac
    
    # バイナリの整理（初回のみ）
    organize_binaries
    
    # バイナリの切り替え
    switch_binary "$target_version"
    
    # 現在のシンボリックリンクを削除
    if [[ -L "$NVIM_CONFIG_DIR/nvim" ]]; then
        rm "$NVIM_CONFIG_DIR/nvim"
    elif [[ -d "$NVIM_CONFIG_DIR/nvim" ]] && [[ ! -L "$NVIM_CONFIG_DIR/nvim" ]]; then
        log_error "警告: $NVIM_CONFIG_DIR/nvim が通常のディレクトリです。手動で移動してください。"
        return 1
    fi
    
    # 新しいシンボリックリンクを作成
    ln -sf "$target_config" "$NVIM_CONFIG_DIR/nvim"
    save_current_version "$target_version"
    
    log_success "Neovim設定を${target_version}版に切り替えました"
    log_info "設定パス: $target_config"
}

# Toggle切り替え（stable⇔nightly）
toggle_version() {
    local current_version
    current_version=$(get_current_version)
    
    case "$current_version" in
        "stable")
            log_info "stable版からnightly版に切り替えます..."
            switch_config "nightly"
            ;;
        "nightly")
            log_info "nightly版からstable版に切り替えます..."
            switch_config "stable"
            ;;
        "unknown")
            log_info "現在のバージョンが不明です。stable版に設定します..."
            switch_config "stable"
            ;;
        *)
            log_error "不明な状態です: $current_version"
            return 1
            ;;
    esac
}

# 現在のバージョンをアップデート
update_current_version() {
    local current_version
    current_version=$(get_current_version)
    
    if [[ "$current_version" == "unknown" ]]; then
        log_error "現在のバージョンが不明です。先に設定を切り替えてください。"
        return 1
    fi
    
    log_info "現在の${current_version}版をアップデートしています..."
    "$DOTFILES_DIR/bin/apps/neovim_installer.sh" install "$current_version"
    
    if [[ $? -eq 0 ]]; then
        log_success "${current_version}版のアップデートが完了しました"
    else
        log_error "${current_version}版のアップデートに失敗しました"
        return 1
    fi
}

# 全バージョンをアップデート
update_all_versions() {
    log_info "すべてのNeovimバージョンをアップデートしています..."
    
    # stable版のアップデート
    if check_neovim_installed "stable"; then
        log_info "stable版をアップデート中..."
        "$DOTFILES_DIR/bin/apps/neovim_installer.sh" install stable
        if [[ $? -eq 0 ]]; then
            log_success "stable版のアップデートが完了しました"
        else
            log_error "stable版のアップデートに失敗しました"
        fi
    else
        log_info "stable版がインストールされていません。スキップします。"
    fi
    
    # nightly版のアップデート
    if check_neovim_installed "nightly"; then
        log_info "nightly版をアップデート中..."
        "$DOTFILES_DIR/bin/apps/neovim_installer.sh" install nightly
        if [[ $? -eq 0 ]]; then
            log_success "nightly版のアップデートが完了しました"
        else
            log_error "nightly版のアップデートに失敗しました"
        fi
    else
        log_info "nightly版がインストールされていません。スキップします。"
    fi
    
    log_success "アップデート処理が完了しました"
}

# 現在の状態を表示
show_status() {
    local current_version
    current_version=$(get_current_version)
    
    echo "🔧 Neovim Version Manager Status"
    echo "=================================="
    
    # 現在のバージョンを強調表示
    case "$current_version" in
        "stable")
            echo "📍 現在のバージョン: 🟢 Stable版 (安定版)"
            ;;
        "nightly")
            echo "📍 現在のバージョン: 🌙 Nightly版 (開発版)"
            ;;
        "unknown")
            echo "📍 現在のバージョン: ❓ 未設定"
            ;;
    esac
    echo ""
    
    # 各バージョンの状態を表示
    echo "📦 インストール状況"
    echo "----------------"
    if check_neovim_installed "stable"; then
        echo "✅ Stable版: インストール済み"
        if [[ -f "$NVIM_STABLE_BIN" ]]; then
            echo "   📁 バイナリパス: $NVIM_STABLE_BIN"
            echo "   🏷️  バージョン: $("$NVIM_STABLE_BIN" --version | head -n1 | sed 's/NVIM //')"
        fi
    else
        echo "❌ Stable版: 未インストール"
    fi
    echo ""
    
    if check_neovim_installed "nightly"; then
        echo "✅ Nightly版: インストール済み"
        if [[ -f "$NVIM_NIGHTLY_BIN" ]]; then
            echo "   📁 バイナリパス: $NVIM_NIGHTLY_BIN"
            echo "   🏷️  バージョン: $("$NVIM_NIGHTLY_BIN" --version | head -n1 | sed 's/NVIM //')"
        fi
    else
        echo "❌ Nightly版: 未インストール"
    fi
    echo ""
    
    echo "🔧 現在のnvimコマンド"
    echo "-------------------"
    if [[ -L "$NVIM_CURRENT_BIN" ]]; then
        echo "🔗 nvimコマンド: $NVIM_CURRENT_BIN -> $(readlink "$NVIM_CURRENT_BIN")"
        echo "🏷️  実行時バージョン: $(nvim --version | head -n1 | sed 's/NVIM //')"
    elif [[ -f "$NVIM_CURRENT_BIN" ]]; then
        echo "📁 nvimコマンド: $NVIM_CURRENT_BIN (通常ファイル)"
        echo "🏷️  実行時バージョン: $(nvim --version | head -n1 | sed 's/NVIM //')"
    else
        echo "❌ nvimコマンド: 未設定"
    fi
    echo ""
    
    echo "⚙️  設定ディレクトリ"
    echo "-------------------"
    echo "📂 Stable設定:  $NVIM_STABLE_CONFIG $([ -d "$NVIM_STABLE_CONFIG" ] && echo "✅" || echo "❌")"
    echo "📂 Nightly設定: $NVIM_NIGHTLY_CONFIG $([ -d "$NVIM_NIGHTLY_CONFIG" ] && echo "✅" || echo "❌")"
    echo ""
    
    if [[ -L "$NVIM_CONFIG_DIR/nvim" ]]; then
        echo "🔗 現在のリンク: $NVIM_CONFIG_DIR/nvim -> $(readlink "$NVIM_CONFIG_DIR/nvim")"
    elif [[ -d "$NVIM_CONFIG_DIR/nvim" ]]; then
        echo "📁 現在の設定: $NVIM_CONFIG_DIR/nvim (通常ディレクトリ)"
    else
        echo "❓ 現在の設定: 未設定"
    fi
    echo ""
    
    echo "🚀 クイックコマンド"
    echo "------------------"
    echo "make nvim-s  # Stable版に切り替え"
    echo "make nvim-n  # Nightly版に切り替え"
    echo "make nvim-t  # Toggle切り替え"
    echo "make nvim-u  # アップデート"
}

# 利用可能なバージョンを表示
show_versions() {
    echo "=== 利用可能なNeovimバージョン ==="
    echo "stable  - 安定版 (推奨: 初心者・仕事用)"
    echo "nightly - 開発版 (推奨: 経験者・最新機能)"
    echo ""
    echo "使用方法:"
    echo "  $(basename "$0") stable   # stable版に切り替え"
    echo "  $(basename "$0") nightly  # nightly版に切り替え"
}

# 初期セットアップ
setup_neovim_switcher() {
    log_info "Neovim切り替え機能のセットアップを開始します..."
    
    # 設定ディレクトリの初期化
    init_config_directories
    
    # 初期状態をstableに設定
    switch_config "stable"
    
    log_success "Neovim切り替え機能のセットアップが完了しました"
    log_info "使用方法:"
    log_info "  $(basename "$0") stable   # stable版に切り替え"
    log_info "  $(basename "$0") nightly  # nightly版に切り替え"
    log_info "  $(basename "$0") status   # 現在の状態を表示"
}

# メイン処理
main() {
    local command="${1:-help}"
    
    case "$command" in
        "setup")
            setup_neovim_switcher
            ;;
        "stable")
            if [[ ! -d "$NVIM_STABLE_CONFIG" ]]; then
                log_error "stable版設定が見つかりません。先に 'setup' を実行してください。"
                exit 1
            fi
            switch_config "stable"
            ;;
        "nightly")
            if [[ ! -d "$NVIM_NIGHTLY_CONFIG" ]]; then
                log_error "nightly版設定が見つかりません。先に 'setup' を実行してください。"
                exit 1
            fi
            switch_config "nightly"
            ;;
        "toggle"|"t")
            toggle_version
            ;;
        "update"|"u")
            update_current_version
            ;;
        "update-all")
            update_all_versions
            ;;
        "status")
            show_status
            ;;
        "list")
            show_versions
            ;;
        # 短縮形コマンド
        "s")
            if [[ ! -d "$NVIM_STABLE_CONFIG" ]]; then
                log_error "stable版設定が見つかりません。先に 'setup' を実行してください。"
                exit 1
            fi
            switch_config "stable"
            ;;
        "n")
            if [[ ! -d "$NVIM_NIGHTLY_CONFIG" ]]; then
                log_error "nightly版設定が見つかりません。先に 'setup' を実行してください。"
                exit 1
            fi
            switch_config "nightly"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "無効なコマンドです: $command"
            show_usage
            exit 1
            ;;
    esac
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi