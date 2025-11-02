#!/usr/bin/env bash

# Network Speed Monitor Plugin for SketchyBar

# Cache file for storing previous values
CACHE_FILE="/tmp/sketchybar_network_cache"

# Get current network stats
current_stats=$(netstat -ibn | awk 'NR>1 && $1 ~ /^en/ {rx+=$7; tx+=$10} END {print rx, tx}')
current_rx=$(echo "$current_stats" | awk '{print $1}')
current_tx=$(echo "$current_stats" | awk '{print $2}')

# Read previous values
if [ -f "$CACHE_FILE" ]; then
    prev_stats=$(cat "$CACHE_FILE")
    prev_rx=$(echo "$prev_stats" | awk '{print $1}')
    prev_tx=$(echo "$prev_stats" | awk '{print $2}')
    prev_time=$(echo "$prev_stats" | awk '{print $3}')
else
    prev_rx=0
    prev_tx=0
    prev_time=$(date +%s)
fi

# Save current values
current_time=$(date +%s)
echo "$current_rx $current_tx $current_time" > "$CACHE_FILE"

# Calculate speed (bytes per second)
time_diff=$((current_time - prev_time))
if [ "$time_diff" -gt 0 ]; then
    rx_speed=$(((current_rx - prev_rx) / time_diff))
    tx_speed=$(((current_tx - prev_tx) / time_diff))
else
    rx_speed=0
    tx_speed=0
fi

# Format speed (convert to KB/s or MB/s)
format_speed() {
    local speed=$1
    if [ "$speed" -gt 1048576 ]; then
        echo "$((speed / 1048576))MB/s"
    elif [ "$speed" -gt 1024 ]; then
        echo "$((speed / 1024))KB/s"
    else
        echo "${speed}B/s"
    fi
}

rx_formatted=$(format_speed "$rx_speed")
tx_formatted=$(format_speed "$tx_speed")

# Catppuccin Mocha colors
ICON_COLOR="0xff89dceb"   # Sky
TEXT_COLOR="0xffcdd6f4"   # Text

# Update SketchyBar item
sketchybar --set "$NAME" \
    label="↓${rx_formatted} ↑${tx_formatted}" \
    icon="󰖟" \
    icon.color="$ICON_COLOR" \
    label.color="$TEXT_COLOR"
