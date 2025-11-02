#!/bin/sh

# Volume Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
ICON_COLOR="0xffb4befe"   # Lavender
TEXT_COLOR="0xffcdd6f4"   # Text

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾"
    ;;
    [3-5][0-9]) ICON="󰖀"
    ;;
    [1-9]|[1-2][0-9]) ICON="󰕿"
    ;;
    *) ICON="󰖁"
  esac

  sketchybar --set "$NAME" \
      icon="$ICON" \
      label="$VOLUME%" \
      icon.color="$ICON_COLOR" \
      label.color="$TEXT_COLOR"
fi
