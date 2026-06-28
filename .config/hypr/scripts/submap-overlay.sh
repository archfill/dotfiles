#!/usr/bin/env bash
# Submap overlay control script.

ACTION="${1:-open}"

case "$ACTION" in
    open)
        ACTIVE_MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused==true) | .id')

        if [[ -z "$ACTIVE_MONITOR" ]]; then
            ACTIVE_MONITOR=0
        fi

        eww open submap-overlay --screen "$ACTIVE_MONITOR"
        ;;
    close)
        eww close submap-overlay
        ;;
    *)
        echo "Usage: $0 {open|close}"
        exit 1
        ;;
esac
