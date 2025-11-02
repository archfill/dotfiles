#!/usr/bin/env bash

# Spotify Player Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
SPOTIFY_GREEN="0xff1DB954"  # Spotify brand green
TEXT_COLOR="0xffcdd6f4"     # Text
SUBTEXT_COLOR="0xffa6adc8"  # Subtext

# Check if Spotify is running
if ! pgrep -x "Spotify" > /dev/null; then
    sketchybar --set "$NAME" \
        drawing=off
    exit 0
fi

# Get Spotify state using AppleScript
STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$STATE" = "playing" ]; then
    # Get track information
    TRACK=$(osascript -e 'tell application "Spotify" to name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track' 2>/dev/null)

    # Truncate long strings
    MAX_LENGTH=30
    if [ ${#TRACK} -gt $MAX_LENGTH ]; then
        TRACK="${TRACK:0:$MAX_LENGTH}..."
    fi
    if [ ${#ARTIST} -gt $MAX_LENGTH ]; then
        ARTIST="${ARTIST:0:$MAX_LENGTH}..."
    fi

    # Update SketchyBar item
    sketchybar --set "$NAME" \
        drawing=on \
        label="$TRACK - $ARTIST" \
        label.color="$TEXT_COLOR" \
        icon="" \
        icon.color="$SPOTIFY_GREEN"
elif [ "$STATE" = "paused" ]; then
    # Show paused state
    sketchybar --set "$NAME" \
        drawing=on \
        label="Paused" \
        label.color="$SUBTEXT_COLOR" \
        icon="" \
        icon.color="$SUBTEXT_COLOR"
else
    # Hide if not playing
    sketchybar --set "$NAME" \
        drawing=off
fi
