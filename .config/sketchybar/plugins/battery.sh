#!/bin/sh

# Battery Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
COLOR_GREEN="0xffa6e3a1"    # Green (full)
COLOR_YELLOW="0xfff9e2af"   # Yellow (medium)
COLOR_RED="0xfff38ba8"      # Red (low)
TEXT_COLOR="0xffcdd6f4"     # Text

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  # No battery (desktop Mac) - show AC power
  sketchybar --set "$NAME" \
      icon="" \
      label="AC" \
      icon.color="$COLOR_GREEN" \
      label.color="$TEXT_COLOR"
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""
  ;;
  *) ICON=""
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
  ICON_COLOR="$COLOR_GREEN"
elif [ "$PERCENTAGE" -lt 20 ]; then
  ICON_COLOR="$COLOR_RED"
elif [ "$PERCENTAGE" -lt 50 ]; then
  ICON_COLOR="$COLOR_YELLOW"
else
  ICON_COLOR="$COLOR_GREEN"
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    label="${PERCENTAGE}%" \
    icon.color="$ICON_COLOR" \
    label.color="$TEXT_COLOR"
