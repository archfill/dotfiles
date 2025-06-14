#!/usr/bin/env bash

# tmux用Neovimバージョン情報表示スクリプト
# このスクリプトは現在のNeovimバージョンと設定タイプを表示します

set -euo pipefail

# キャッシュファイル（5秒間有効）
readonly CACHE_FILE="/tmp/tmux_nvim_info_cache"
readonly CACHE_DURATION=5

# 関数: キャッシュから読み込み
get_cached_info() {
    if [[ -f "$CACHE_FILE" ]]; then
        local cache_time
        cache_time=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
        local current_time
        current_time=$(date +%s)
        
        if (( current_time - cache_time < CACHE_DURATION )); then
            cat "$CACHE_FILE"
            return 0
        fi
    fi
    return 1
}

# 関数: Neovimバージョン情報の取得
get_nvim_info() {
    # nvimコマンドが利用可能かチェック
    if ! command -v nvim >/dev/null 2>&1; then
        echo "󰈅 N/A"
        return
    fi
    
    # バージョン情報を取得（高速化のため--clean使用）
    local version
    version=$(nvim --version --clean 2>/dev/null | head -n1 | sed 's/NVIM //' | cut -d' ' -f1)
    
    # 現在の設定タイプを判定（統合システム対応）
    local config_type=""
    local icon=""
    
    # 方法1: 状態ファイルから判定（優先）
    if [[ -f "$HOME/.neovim_version_state" ]]; then
        local state_content
        state_content=$(cat "$HOME/.neovim_version_state" 2>/dev/null || echo "")
        
        case "$state_content" in
            "stable")
                config_type="S"
                icon="󰟢"  # 安定版アイコン（盾）
                ;;
            "nightly")
                config_type="N"
                icon="󰌌"  # 開発版アイコン（月）
                ;;
            *)
                config_type="?"
                icon="󰈅"  # 不明アイコン
                ;;
        esac
    # 方法2: 従来のシンボリックリンク判定（フォールバック）
    elif [[ -L "$HOME/.config/nvim" ]]; then
        local target
        target=$(readlink "$HOME/.config/nvim" 2>/dev/null || echo "")
        
        case "$target" in
            *nvim-stable*)
                config_type="S"
                icon="󰟢"  # 安定版アイコン（盾）
                ;;
            *nvim-nightly*)
                config_type="N"
                icon="󰌌"  # 開発版アイコン（月）
                ;;
            *nvim-unified*)
                # 統合システムの場合、バイナリから判定
                local nvim_binary
                nvim_binary=$(readlink "$HOME/.local/bin/nvim" 2>/dev/null || echo "")
                case "$nvim_binary" in
                    *nvim-stable*)
                        config_type="S"
                        icon="󰟢"
                        ;;
                    *nvim-nightly*)
                        config_type="N"
                        icon="󰌌"
                        ;;
                    *)
                        config_type="U"  # 統合システム（Unified）
                        icon="󰻧"  # 統合アイコン
                        ;;
                esac
                ;;
            *)
                config_type="?"
                icon="󰈅"  # 不明アイコン
                ;;
        esac
    else
        config_type="D"  # Default
        icon="󰈸"  # デフォルトアイコン
    fi
    
    # バージョンを短縮表示（メジャー.マイナーのみ）
    local short_version
    short_version=$(echo "$version" | sed -E 's/^v?([0-9]+\.[0-9]+).*/\1/')
    
    echo "$icon $short_version$config_type"
}

# メイン実行
if get_cached_info; then
    exit 0
fi

# キャッシュが無効な場合、新しい情報を取得してキャッシュに保存
result=$(get_nvim_info)
echo "$result" | tee "$CACHE_FILE"