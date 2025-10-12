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
        echo "󰅙 N/A"
        return
    fi

    # バージョン情報を取得（高速化のため--clean使用）
    local version
    version=$(nvim --version --clean 2>/dev/null | head -n1 | sed 's/NVIM //' | cut -d' ' -f1)

    # 設定タイプを判定（デフォルト: D）
    local config_type="D"
    local icon="󰅴"  # デフォルトアイコン（cog）

    # カスタム管理システムのチェック（~/.local/bin/nvim）
    # Linux/macOS: AppImage/tar.gz方式でstable/nightlyを管理
    if [[ -L "$HOME/.local/bin/nvim" ]]; then
        local nvim_target
        nvim_target=$(readlink "$HOME/.local/bin/nvim" 2>/dev/null || echo "")

        case "$nvim_target" in
            *nvim-stable*|*stable*)
                config_type="S"
                icon="󰗠"  # 安定版アイコン（shield_check）
                ;;
            *nvim-nightly*|*nightly*)
                config_type="N"
                icon="󱎖"  # 開発版アイコン（flask）
                ;;
        esac
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