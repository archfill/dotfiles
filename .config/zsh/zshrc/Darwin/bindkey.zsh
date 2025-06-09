# macOS-specific key bindings

# macOS Terminal.app key bindings
bindkey '^[[1;5C' forward-word      # Cmd+Right
bindkey '^[[1;5D' backward-word     # Cmd+Left
bindkey '^[[H' beginning-of-line    # Cmd+Left (some terminals)
bindkey '^[[F' end-of-line          # Cmd+Right (some terminals)

# Option+Left/Right word navigation
bindkey '^[^[[C' forward-word       # Option+Right
bindkey '^[^[[D' backward-word      # Option+Left

# macOS specific shortcuts
bindkey '^[^?' backward-kill-word   # Option+Backspace