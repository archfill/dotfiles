#!/usr/bin/env bash

# Memory Usage Monitor Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Get memory usage using vm_stat
pagesize=$(pagesize)
stats=$(vm_stat)

pages_free=$(echo "$stats" | grep 'Pages free' | awk '{print $3}' | tr -d '.')
pages_active=$(echo "$stats" | grep 'Pages active' | awk '{print $3}' | tr -d '.')
pages_inactive=$(echo "$stats" | grep 'Pages inactive' | awk '{print $3}' | tr -d '.')
pages_wired=$(echo "$stats" | grep 'Pages wired down' | awk '{print $4}' | tr -d '.')

# Calculate used memory in GB
mem_used=$((($pages_active + $pages_inactive + $pages_wired) * $pagesize / 1024 / 1024 / 1024))
mem_total=$((($pages_free + $pages_active + $pages_inactive + $pages_wired) * $pagesize / 1024 / 1024 / 1024))

# Calculate percentage
if [ "$mem_total" -gt 0 ]; then
    mem_percent=$((mem_used * 100 / mem_total))
else
    mem_percent=0
fi

# Catppuccin Mocha colors
COLOR_NORMAL="0xffa6e3a1"   # Green
COLOR_WARNING="0xfff9e2af"  # Yellow
COLOR_CRITICAL="0xfff38ba8" # Red
TEXT_COLOR="0xffcdd6f4"     # Text

# Color based on usage
if [ "$mem_percent" -gt 80 ]; then
    ICON_COLOR="$COLOR_CRITICAL"
elif [ "$mem_percent" -gt 60 ]; then
    ICON_COLOR="$COLOR_WARNING"
else
    ICON_COLOR="$COLOR_NORMAL"
fi

# Update SketchyBar item
sketchybar --set "$NAME" \
    label="${mem_used}GB" \
    icon="󰍛" \
    icon.color="$ICON_COLOR" \
    label.color="$TEXT_COLOR"
