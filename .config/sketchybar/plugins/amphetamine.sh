#!/bin/bash

# Amphetamine status indicator for SketchyBar
# Checks if Amphetamine is running and active

# Check if Amphetamine process is running
if pgrep -x "Amphetamine" > /dev/null; then
    # Check specifically for Amphetamine in the pmset assertions
    amphetamine_assertion=$(pmset -g assertions | grep -c "Amphetamine")

    if [[ "$amphetamine_assertion" -gt 0 ]]; then
        # Session is likely active (system sleep prevented)
        ICON="󰛨"  # Coffee cup icon - active
        COLOR="0xff91d42a"  # Green color for active
        BACKGROUND_COLOR="0x4091d42a"  # Semi-transparent green background
    else
        # Amphetamine is running but no active session detected
        ICON="󰾫"  # Sleep icon - inactive
        COLOR="0xffffffff"  # White color for inactive
        BACKGROUND_COLOR="0x40ffffff"  # Semi-transparent white background
    fi
else
    # Amphetamine is not running
    ICON="󰾫"  # Sleep icon
    COLOR="0xff787880"  # Gray color for not running
    BACKGROUND_COLOR="0x40787880"  # Semi-transparent gray background
fi

sketchybar --set amphetamine \
    icon="$ICON" \
    icon.color="$COLOR" \
    background.color="$BACKGROUND_COLOR"