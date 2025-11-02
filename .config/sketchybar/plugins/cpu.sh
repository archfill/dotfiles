#!/usr/bin/env bash

# CPU Usage Monitor Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Get CPU usage percentage
CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
CPU_PERCENT=$(echo "$CPU_USAGE" | awk '{printf "%.0f", $1}')

# Catppuccin Mocha colors
COLOR_NORMAL="0xff89b4fa"   # Blue
COLOR_WARNING="0xfff9e2af"  # Yellow
COLOR_CRITICAL="0xfff38ba8" # Red
TEXT_COLOR="0xffcdd6f4"     # Text

# Color based on usage
if [ "$CPU_PERCENT" -gt 80 ]; then
    ICON_COLOR="$COLOR_CRITICAL"
elif [ "$CPU_PERCENT" -gt 50 ]; then
    ICON_COLOR="$COLOR_WARNING"
else
    ICON_COLOR="$COLOR_NORMAL"
fi

# Update SketchyBar item with SF Symbols style icon
sketchybar --set "$NAME" \
    label="${CPU_PERCENT}%" \
    icon="󰻠" \
    icon.color="$ICON_COLOR" \
    label.color="$TEXT_COLOR"
