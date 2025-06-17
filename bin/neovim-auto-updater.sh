#!/usr/bin/env bash
# neovim-auto-updater.sh
# 自動更新システム（cron/systemdタイマー対応）

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TRACKER_SCRIPT="$SCRIPT_DIR/neovim-head-tracker.sh"
readonly UPDATE_LOG="$HOME/.local/neovim-head/auto-update.log"
readonly LOCK_FILE="/tmp/neovim-auto-updater.lock"

# ===== ロック管理 =====
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Another instance is running (PID: $pid)"
            exit 1
        else
            echo "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
}

# ===== ログ管理 =====
log_auto_update() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$UPDATE_LOG"
}

# ===== 自動更新実行 =====
run_auto_update() {
    acquire_lock
    
    log_auto_update "Starting automatic update check"
    
    if [[ ! -x "$TRACKER_SCRIPT" ]]; then
        log_auto_update "ERROR: Tracker script not found or not executable: $TRACKER_SCRIPT"
        exit 1
    fi
    
    # 更新チェック実行
    if "$TRACKER_SCRIPT" update >> "$UPDATE_LOG" 2>&1; then
        log_auto_update "Update completed successfully"
        
        # Neovimが実行中の場合は通知
        if pgrep nvim > /dev/null; then
            log_auto_update "WARNING: Neovim is currently running. Restart required for new version."
            
            # 通知がある場合は送信
            if command -v notify-send &> /dev/null; then
                notify-send "Neovim Updated" "Neovim has been updated to the latest HEAD. Restart required."
            fi
        fi
    else
        log_auto_update "Update failed or no updates available"
    fi
}

# ===== Systemdタイマー設定 =====
install_systemd_timer() {
    local timer_frequency="${1:-daily}"
    local user_systemd_dir="$HOME/.config/systemd/user"
    
    mkdir -p "$user_systemd_dir"
    
    # サービス定義
    cat > "$user_systemd_dir/neovim-auto-update.service" << EOF
[Unit]
Description=Neovim HEAD Auto Update
After=network-online.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/neovim-auto-updater.sh
Environment=PATH=/usr/local/bin:/usr/bin:/bin
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

    # タイマー定義
    cat > "$user_systemd_dir/neovim-auto-update.timer" << EOF
[Unit]
Description=Neovim HEAD Auto Update Timer
Requires=neovim-auto-update.service

[Timer]
OnCalendar=$timer_frequency
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
EOF

    # サービス有効化
    systemctl --user daemon-reload
    systemctl --user enable neovim-auto-update.timer
    systemctl --user start neovim-auto-update.timer
    
    echo "Systemd timer installed and started"
    echo "Frequency: $timer_frequency"
    echo ""
    echo "Control commands:"
    echo "  systemctl --user status neovim-auto-update.timer"
    echo "  systemctl --user stop neovim-auto-update.timer"
    echo "  systemctl --user disable neovim-auto-update.timer"
}

# ===== Cron設定 =====
install_cron_job() {
    local cron_time="${1:-0 2 * * *}"  # デフォルト: 毎日2時
    
    # 既存のcronジョブをチェック
    if crontab -l 2>/dev/null | grep -q "neovim-auto-updater"; then
        echo "Cron job already exists. Removing old one..."
        crontab -l 2>/dev/null | grep -v "neovim-auto-updater" | crontab -
    fi
    
    # 新しいcronジョブを追加
    (crontab -l 2>/dev/null; echo "$cron_time $SCRIPT_DIR/neovim-auto-updater.sh") | crontab -
    
    echo "Cron job installed"
    echo "Schedule: $cron_time"
    echo ""
    echo "Control commands:"
    echo "  crontab -l  # List cron jobs"
    echo "  crontab -e  # Edit cron jobs"
}

# ===== メイン処理 =====
main() {
    case "${1:-run}" in
        "run")
            run_auto_update
            ;;
        "install-systemd")
            local frequency="${2:-daily}"
            install_systemd_timer "$frequency"
            ;;
        "install-cron")
            local schedule="${2:-0 2 * * *}"
            install_cron_job "$schedule"
            ;;
        "status")
            echo "=== Auto Update Status ==="
            
            if systemctl --user is-active neovim-auto-update.timer &>/dev/null; then
                echo "Systemd timer: ACTIVE"
                systemctl --user status neovim-auto-update.timer --no-pager -l
            else
                echo "Systemd timer: INACTIVE"
            fi
            
            echo ""
            if crontab -l 2>/dev/null | grep -q "neovim-auto-updater"; then
                echo "Cron job: ACTIVE"
                crontab -l | grep "neovim-auto-updater"
            else
                echo "Cron job: INACTIVE"
            fi
            
            echo ""
            if [[ -f "$UPDATE_LOG" ]]; then
                echo "Recent updates:"
                tail -10 "$UPDATE_LOG"
            else
                echo "No update log found"
            fi
            ;;
        "uninstall")
            echo "Removing auto-update services..."
            
            # Systemd timer
            if systemctl --user is-enabled neovim-auto-update.timer &>/dev/null; then
                systemctl --user stop neovim-auto-update.timer
                systemctl --user disable neovim-auto-update.timer
                rm -f "$HOME/.config/systemd/user/neovim-auto-update."{service,timer}
                systemctl --user daemon-reload
                echo "Systemd timer removed"
            fi
            
            # Cron job
            if crontab -l 2>/dev/null | grep -q "neovim-auto-updater"; then
                crontab -l 2>/dev/null | grep -v "neovim-auto-updater" | crontab -
                echo "Cron job removed"
            fi
            ;;
        *)
            echo "Usage: $0 {run|install-systemd|install-cron|status|uninstall}"
            echo ""
            echo "Commands:"
            echo "  run                      - Run update check (default)"
            echo "  install-systemd [freq]   - Install systemd timer (daily, hourly, weekly)"
            echo "  install-cron [schedule]  - Install cron job (default: '0 2 * * *')"
            echo "  status                   - Show auto-update status"
            echo "  uninstall                - Remove all auto-update services"
            echo ""
            echo "Examples:"
            echo "  $0 install-systemd daily"
            echo "  $0 install-cron '0 3 * * *'"
            exit 1
            ;;
    esac
}

main "$@"