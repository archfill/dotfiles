#!/usr/bin/env bash

# IME Indicator Plugin for SketchyBar
# Shows current input method (English/Japanese/etc)

# Method 1: inputsource command (most reliable)
if command -v inputsource >/dev/null 2>&1; then
    current_input_source=$(inputsource | grep -E "^\*" | sed 's/^* //')
fi

# Method 2: HIToolbox plist (system standard, fast)
if [[ -z "$current_input_source" ]]; then
    # Check for Google IME first
    google_ime=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | \
        grep -A 2 'com.google.inputmethod.Japanese' | \
        grep '"Input Mode"' | \
        sed -E 's/.*"Input Mode" = "([^"]*)".*/\1/' | \
        head -1)

    if [[ -n "$google_ime" ]]; then
        current_input_source="Google IME Japanese"
    else
        # Fallback to standard keyboard layout detection
        current_input_source=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | \
            grep '"KeyboardLayout Name"' | \
            sed -E 's/.*"KeyboardLayout Name" = "?([^"]*)"?.*/\1/' | \
            head -1)
    fi
fi

# Method 3: AppleScript via SystemUIServer (alternative)
if [[ -z "$current_input_source" ]]; then
    current_input_source=$(osascript -e 'tell application "System Events" to tell process "SystemUIServer" to return name of menu bar item 1 of menu bar 1' 2>/dev/null)
fi

# Fallback: try another method
if [[ -z "$current_input_source" ]]; then
    # Get from Text Input Source
    current_input_source=$(osascript -e '
        tell application "System Events"
            try
                set inputSource to (get value of attribute "AXDescription" of (first menu bar item of menu bar 1 of application process "SystemUIServer" whose description contains "Input"))
                return inputSource
            on error
                return "EN"
            end try
        end tell
    ' 2>/dev/null)
fi

# Catppuccin Mocha colors
TEXT_COLOR="0xffffffff"        # White text
ICON_COLOR="0xffffffff"        # White icon
BG_RED="0xccf38ba8"           # Red (Japanese)
BG_GREEN="0xcca6e3a1"         # Green (English)
BG_PEACH="0xccfab387"         # Peach (Korean)
BG_SAPPHIRE="0xcc74c7ec"      # Sapphire (Chinese)
BG_GRAY="0xcc6c7086"          # Gray (Unknown)

# Determine display text and color based on input source
case "$current_input_source" in
    *"Google IME Japanese"*|*"Japanese"*|*"Hiragana"*|*"ひらがな"*|*"日本語"*)
        DISPLAY_TEXT="JP"
        ICON="􀇳"
        BG_COLOR="$BG_RED"
        ;;
    *"ABC"*|*"English"*|*"US"*|*"英字"*)
        DISPLAY_TEXT="EN"
        ICON="􀇳"
        BG_COLOR="$BG_GREEN"
        ;;
    *"Korean"*|*"한국어"*)
        DISPLAY_TEXT="KR"
        ICON="􀇳"
        BG_COLOR="$BG_PEACH"
        ;;
    *"Chinese"*|*"中文"*)
        DISPLAY_TEXT="CN"
        ICON="􀇳"
        BG_COLOR="$BG_SAPPHIRE"
        ;;
    *)
        DISPLAY_TEXT="??"
        ICON="􀇳"
        BG_COLOR="$BG_GRAY"
        ;;
esac

# Update SketchyBar
sketchybar --set $NAME \
    icon="$ICON" \
    label="$DISPLAY_TEXT" \
    background.color="$BG_COLOR" \
    icon.color="$ICON_COLOR" \
    label.color="$TEXT_COLOR"
