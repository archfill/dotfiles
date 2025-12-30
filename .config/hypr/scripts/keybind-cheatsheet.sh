#!/bin/bash
# Hyprland Keybind Cheatsheet
# Parses hyprland.conf and displays keybindings in fuzzel

CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"

# Parse keybindings from config
parse_keybinds() {
    grep -E "^bind[m]?\s*=" "$CONFIG_FILE" | while read -r line; do
        # Remove inline comments first
        line="${line%%#*}"

        # Remove "bind = " or "bindm = " prefix
        binding="${line#*= }"

        # Split by comma
        IFS=',' read -r mods key action args <<< "$binding"

        # Clean up whitespace
        mods=$(echo "$mods" | xargs)
        key=$(echo "$key" | xargs)
        action=$(echo "$action" | xargs)
        args=$(echo "$args" | xargs)

        # Format modifier keys
        mods="${mods//\$mainMod/Super}"

        # Create key display
        if [[ -n "$mods" ]]; then
            key_display="$mods + $key"
        else
            key_display="$key"
        fi

        # Human-readable descriptions
        case "$action" in
            exec) desc="$args" ;;
            killactive) desc="Close window" ;;
            exit) desc="Exit Hyprland" ;;
            togglefloating) desc="Toggle floating" ;;
            pseudo) desc="Pseudo-tile (dwindle)" ;;
            togglesplit) desc="Toggle split (dwindle)" ;;
            fullscreen) desc="Fullscreen" ;;
            movefocus) desc="Focus $args" ;;
            movewindow)
                if [[ "$args" == mon:* ]]; then
                    desc="Window to monitor ${args#mon:}"
                else
                    desc="Move window $args"
                fi
                ;;
            workspace)
                if [[ "$args" == e+* || "$args" == e-* ]]; then
                    desc="Scroll workspaces"
                else
                    desc="Workspace $args"
                fi
                ;;
            movetoworkspace) desc="Send to workspace $args" ;;
            togglegroup) desc="Toggle tab group" ;;
            changegroupactive)
                [[ "$args" == "f" ]] && desc="Next tab in group" || desc="Prev tab in group"
                ;;
            moveoutofgroup) desc="Ungroup window" ;;
            moveintogroup) desc="Group window $args" ;;
            movewindow) desc="Move window" ;;
            resizewindow) desc="Resize window" ;;
            *) desc="$action" ;;
        esac

        printf "%-28s  %s\n" "$key_display" "$desc"
    done
}

# Run fuzzel with keybindings
parse_keybinds | fuzzel --dmenu --prompt=" Keybinds: " --width=60 --lines=25
