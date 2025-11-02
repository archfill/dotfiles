#!/usr/bin/env bash

# Weather Information Plugin for SketchyBar
# Uses wttr.in API for weather data

# Cache settings
CACHE_FILE="/tmp/sketchybar_weather_cache"
CACHE_DURATION=1800  # 30 minutes in seconds

# Check if cache is valid
if [ -f "$CACHE_FILE" ]; then
    cache_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    age=$((current_time - cache_time))

    if [ "$age" -lt "$CACHE_DURATION" ]; then
        # Use cached data
        cached_data=$(cat "$CACHE_FILE")
        sketchybar --set "$NAME" label="$cached_data"
        exit 0
    fi
fi

# Fetch weather data (format: temperature and weather icon)
# Using Tokyo as default location (change if needed)
weather_data=$(curl -s "wttr.in/?format=%t+%c" 2>/dev/null)

# Catppuccin Mocha colors
ICON_COLOR="0xfffab387"   # Peach
TEXT_COLOR="0xffcdd6f4"   # Text

# Check if data was fetched successfully
if [ -n "$weather_data" ]; then
    # Save to cache
    echo "$weather_data" > "$CACHE_FILE"

    # Update SketchyBar item
    sketchybar --set "$NAME" \
        label="$weather_data" \
        icon="󰖐" \
        icon.color="$ICON_COLOR" \
        label.color="$TEXT_COLOR"
else
    # If fetch failed, show error or use cache
    if [ -f "$CACHE_FILE" ]; then
        cached_data=$(cat "$CACHE_FILE")
        sketchybar --set "$NAME" \
            label="$cached_data" \
            icon.color="$ICON_COLOR" \
            label.color="$TEXT_COLOR"
    else
        sketchybar --set "$NAME" \
            label="--" \
            icon.color="$ICON_COLOR" \
            label.color="$TEXT_COLOR"
    fi
fi
