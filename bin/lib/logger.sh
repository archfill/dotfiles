#!/usr/bin/env bash

# logger.sh - シンプルなログヘルパー
# 使用方法: source bin/lib/logger.sh && run_with_log "script_name" command args...

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
LOG_DIR="${DOTFILES_DIR}/.logs"

# ログファイル作成
create_log_file() {
    local script_name="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)

    mkdir -p "$LOG_DIR"

    export DOTFILES_LOG_FILE="${LOG_DIR}/${script_name}_${timestamp}.log"
    echo "$DOTFILES_LOG_FILE"
}

# ログ付きでコマンド実行
run_with_log() {
    local script_name="$1"
    shift

    local log_file=$(create_log_file "$script_name")

    echo "📝 Log file: $log_file"
    echo ""

    # teeで標準出力/エラー出力の両方をファイルと画面に出力
    "$@" 2>&1 | tee "$log_file"

    local exit_code=${PIPESTATUS[0]}

    if [[ $exit_code -eq 0 ]]; then
        echo ""
        echo "✅ Log saved to: $log_file"
    else
        echo ""
        echo "❌ Error occurred. Log saved to: $log_file"
    fi

    return $exit_code
}
