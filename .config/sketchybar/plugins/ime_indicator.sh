#!/bin/bash

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

# Determine display text and color based on input source
case "$current_input_source" in
    *"Google IME Japanese"*|*"Japanese"*|*"Hiragana"*|*"ひらがな"*|*"日本語"*)
        DISPLAY_TEXT="JP"
        ICON="􀇳"
        BG_COLOR="0x80ff6b6b"  # Red background for Japanese
        ;;
    *"ABC"*|*"English"*|*"US"*|*"英字"*)
        DISPLAY_TEXT="EN"
        ICON="􀇳"
        BG_COLOR="0x803fb950"  # Green background for English
        ;;
    *"Korean"*|*"한국어"*)
        DISPLAY_TEXT="KR"
        ICON="􀇳"
        BG_COLOR="0x80f0a060"  # Orange background for Korean
        ;;
    *"Chinese"*|*"中文"*)
        DISPLAY_TEXT="CN"
        ICON="􀇳"
        BG_COLOR="0x8060a0f0"  # Blue background for Chinese
        ;;
    *)
        DISPLAY_TEXT="??"
        ICON="􀇳"
        BG_COLOR="0x80808080"  # Gray background for unknown
        ;;
esac

# Update SketchyBar
sketchybar --set $NAME \
    icon="$ICON" \
    label="$DISPLAY_TEXT" \
    background.color="$BG_COLOR" \
    icon.color=0xffffffff \
    label.color=0xffffffff