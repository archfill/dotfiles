#!/usr/bin/env bash

# Amphetamine status indicator for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
COLOR_ACTIVE="0xffa6e3a1"      # Green (active)
COLOR_INACTIVE="0xffcdd6f4"    # Text (inactive)
COLOR_GRAY="0xff6c7086"        # Overlay0 (not running)
BG_ACTIVE="0xcca6e3a1"         # Green background
BG_INACTIVE="0xcc313244"       # Surface0
BG_GRAY="0xcc313244"           # Surface0

# Check if Amphetamine process is running
if pgrep -x "Amphetamine" > /dev/null; then
    # Check specifically for Amphetamine in the pmset assertions
    amphetamine_assertion=$(pmset -g assertions | grep -c "Amphetamine")

    if [[ "$amphetamine_assertion" -gt 0 ]]; then
        # Session is likely active (system sleep prevented)
        ICON="󰛨"  # Coffee cup icon - active
        COLOR="$COLOR_ACTIVE"
        BACKGROUND_COLOR="$BG_ACTIVE"
    else
        # Amphetamine is running but no active session detected
        ICON="󰾫"  # Sleep icon - inactive
        COLOR="$COLOR_INACTIVE"
        BACKGROUND_COLOR="$BG_INACTIVE"
    fi
else
    # Amphetamine is not running
    ICON="󰾫"  # Sleep icon
    COLOR="$COLOR_GRAY"
    BACKGROUND_COLOR="$BG_GRAY"
fi

sketchybar --set amphetamine \
    icon="$ICON" \
    icon.color="$COLOR" \
    background.color="$BACKGROUND_COLOR"
