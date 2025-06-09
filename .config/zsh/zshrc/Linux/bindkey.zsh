# Linux-specific key bindings

# Common Linux terminal key bindings
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End
bindkey '^[[3~' delete-char         # Delete

# History navigation with PageUp/PageDown
bindkey '^[[5~' history-beginning-search-backward  # PageUp
bindkey '^[[6~' history-beginning-search-forward   # PageDown

# Alt+Backspace to delete word backward
bindkey '^[^?' backward-kill-word