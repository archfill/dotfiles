#!/bin/bash
# Hyprland Keybind Cheatsheet
# Parses keybind config and displays keybindings in rofi with categories

KEYBINDS_FILE="$HOME/.config/hypr/modules/keybinds.conf"

# Parse and format keybindings using awk
generate_cheatsheet() {
    awk '
    BEGIN {
        # Category definitions: start pattern, icon, title
        # Icons from Nerd Fonts (same as rofi config.rasi)
        categories[1] = "A. App Launcher|󰀻  Apps"
        categories[2] = "B. Window Basic|󰖲  Window"
        categories[3] = "C. Window Layout|"
        categories[4] = "D. Workspace|󰍹  Workspace"
        categories[5] = "E. Group|󰓩  Groups"
        categories[6] = "F. Screenshot|󰄀  Screenshot"
        categories[7] = "G. System|󰒓  System"
        num_categories = 7
        current_cat = 0
        printed_header = 0
    }

    # Check for category headers
    /^# [A-H]\. / {
        for (i = 1; i <= num_categories; i++) {
            split(categories[i], parts, "|")
            if (index($0, parts[1]) > 0) {
                current_cat = i
                printed_header = 0
                break
            }
        }
        next
    }

    # Skip submap internals (indented binds)
    /^  +bind/ { next }

    # Process bind lines
    /^bind[m]? = / {
        if (current_cat == 0) next

        # Print category header if not yet printed
        if (!printed_header) {
            split(categories[current_cat], parts, "|")
            if (parts[2] != "") {
                if (NR > 20) print ""
                print parts[2]
            }
            printed_header = 1
        }

        # Remove "bind = " or "bindm = " prefix and comments
        line = $0
        sub(/^bind[m]? = /, "", line)
        sub(/#.*$/, "", line)

        # Split by comma
        n = split(line, fields, ",")
        mods = fields[1]
        key = fields[2]
        action = fields[3]
        args = ""
        for (i = 4; i <= n; i++) {
            args = args (i > 4 ? "," : "") fields[i]
        }

        # Trim whitespace
        gsub(/^[ \t]+|[ \t]+$/, "", mods)
        gsub(/^[ \t]+|[ \t]+$/, "", key)
        gsub(/^[ \t]+|[ \t]+$/, "", action)
        gsub(/^[ \t]+|[ \t]+$/, "", args)

        # Format modifiers
        gsub(/\$mainMod/, "Super", mods)
        gsub(/\$hyper/, "Hyper", mods)
        gsub(/SHIFT/, "Shift", mods)
        gsub(/CTRL/, "Ctrl", mods)
        gsub(/ALT/, "Alt", mods)

        # Build key display
        if (mods != "") {
            key_display = mods " + " key
        } else {
            key_display = key
        }

        # Build description
        if (action == "exec") {
            desc = args
            # Shorten long commands
            gsub(/pkill [a-z-]+ \|\| /, "", desc)
            gsub(/~\/\.config\/hypr\/scripts\//, "", desc)
            gsub(/alacritty --class clipse -e /, "", desc)
            gsub(/ \| rofi -dmenu.*$/, "", desc)
            gsub(/rofi -show /, "", desc)
            gsub(/swaync-client -t -sw/, "Notifications", desc)
            if (length(desc) > 30) desc = substr(desc, 1, 27) "..."
        } else if (action == "killactive") desc = "Close window"
        else if (action == "exit") desc = "Exit Hyprland"
        else if (action == "togglefloating") desc = "Toggle floating"
        else if (action == "togglesplit") desc = "Toggle split"
        else if (action == "fullscreen") desc = "Fullscreen"
        else if (action == "movefocus") desc = "Focus " args
        else if (action == "movewindow") {
            if (index(args, "mon:") == 1) desc = "To monitor " substr(args, 5)
            else desc = "Move " args
        }
        else if (action == "resizeactive") desc = "Resize"
        else if (action == "workspace") {
            if (index(args, "e+") == 1 || index(args, "e-") == 1) desc = "Scroll workspace"
            else desc = "Workspace " args
        }
        else if (action == "movetoworkspace") desc = "Send to WS " args
        else if (action == "togglegroup") desc = "Toggle group"
        else if (action == "changegroupactive") {
            if (args == "f") desc = "Next tab"
            else desc = "Prev tab"
        }
        else if (action == "moveoutofgroup") desc = "Ungroup"
        else if (action == "moveintogroup") desc = "Group " args
        else desc = action

        printf "%-28s %s\n", key_display, desc
    }
    ' "$KEYBINDS_FILE"
}

# Run rofi with custom cheatsheet theme
generate_cheatsheet | rofi -dmenu -p "󰌌 Keys" -i \
    -theme ~/.config/rofi/cheatsheet.rasi
