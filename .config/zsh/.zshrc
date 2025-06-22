# Safe source function for optional files
source-safe() { if [ -f "$1" ]; then source "$1"; fi }

# Current platform detection
CURRENT_PLATFORM="$(uname)"

# 1. Load fundamental options first
source "$ZRCDIR/options.zsh"

# 2. Load shared base configuration
source "$ZRCDIR/base.zsh"

# 3. Load SDK and development tools configuration
source "$ZRCDIR/sdk.zsh"
source "$ZRCDIR/tools.zsh"

# 4. Load platform-specific base configuration (may override shared settings)
source-safe "$ZRCDIR/$CURRENT_PLATFORM/base.zsh"

# 5. Load shared functions
source "$ZRCDIR/functions.zsh"

# 6. Load platform-specific functions
source-safe "$ZRCDIR/$CURRENT_PLATFORM/functions.zsh"

# 7. Load completions and plugins (before aliases to allow alias completion)
source "$ZRCDIR/plugins.zsh"
source-safe "$ZRCDIR/$CURRENT_PLATFORM/plugins.zsh"

# 8. Load shared aliases
source "$ZRCDIR/alias.zsh"

# 9. Load platform-specific aliases (may override shared aliases)
source-safe "$ZRCDIR/$CURRENT_PLATFORM/alias.zsh"

# 10. Load key bindings last
source "$ZRCDIR/bindkey.zsh"
source-safe "$ZRCDIR/$CURRENT_PLATFORM/bindkey.zsh"

# 11. Load user-specific overrides (highest priority)
source-safe "$HOME/zshrc_local.zsh"
