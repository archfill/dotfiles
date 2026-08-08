#!/usr/bin/env bash
# Hyprland Keybind Cheatsheet
# Reads descriptions from the keybinds loaded by Hyprland, not from source text.

generate_cheatsheet() {
    local output

    if ! output="$(hyprctl -j binds 2>/dev/null | jq -r '
        [ .[]
          | select(.description? and (.description | startswith("cheatsheet|")))
          | (.description | split("|"))
          | select(length == 4)
          | { category: .[1], key: .[2], description: .[3] }
        ]
        | sort_by(.category, .key)
        | group_by(.category)[]
        | (.[0].category | sub("^[0-9]+ "; "") | "󰌌  " + .),
          (.[] | "\(.key)  —  \(.description)"),
          ""
    ')"; then
        printf 'Unable to read loaded Hyprland keybinds.\n'
        return
    fi

    if [[ -n "$output" ]]; then
        printf '%s\n' "$output"
    else
        printf 'No documented Lua keybinds are loaded. Reload Hyprland after applying the configuration.\n'
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    generate_cheatsheet | rofi -dmenu -p "󰌌 Keys" -i \
        -theme ~/.config/rofi/cheatsheet.rasi
fi
