#!/usr/bin/env bash
# Submap overlay control script
# Opens EWW overlay on the active monitor

ACTION="${1:-open}"

case "$ACTION" in
    open)
        # Get active monitor ID from hyprctl
        ACTIVE_MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused==true) | .id')

        # Default to monitor 0 if detection fails
        if [[ -z "$ACTIVE_MONITOR" ]]; then
            ACTIVE_MONITOR=0
        fi

        # Open EWW overlay on active monitor
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
