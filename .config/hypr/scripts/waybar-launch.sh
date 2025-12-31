#!/usr/bin/env bash
# =====================================================
# Waybar Launch Script
# =====================================================
# Usage:
#   waybar-launch.sh          # Start or restart waybar
#   waybar-launch.sh kill     # Kill waybar
#   waybar-launch.sh status   # Check status
# =====================================================

set -euo pipefail

CONFIG_DIR="${HOME}/.config/waybar"

case "${1:-}" in
    kill)
        if pgrep -x waybar >/dev/null; then
            killall waybar
            echo "Waybar stopped"
        else
            echo "Waybar is not running"
        fi
        ;;
    status)
        if pgrep -x waybar >/dev/null; then
            echo "Waybar is running (PID: $(pgrep -x waybar))"
        else
            echo "Waybar is not running"
        fi
        ;;
    *)
        # Kill existing waybar
        if pgrep -x waybar >/dev/null; then
            killall waybar
            sleep 0.3
        fi

        # Start waybar
        waybar -c "${CONFIG_DIR}/config.jsonc" -s "${CONFIG_DIR}/style.css" &
        disown

        echo "Waybar started"
        ;;
esac
