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

# 11. Ensure Nix profile takes precedence on PATH (must run after all
#     other PATH-modifying scripts in zshrc/zshenv)
source "$ZRCDIR/nix.zsh"

# 12. Load user-specific overrides (highest priority)
source-safe "$HOME/zshrc_local.zsh"

# ===== Java/Maven (mise) =====
# Note: Java and Maven are now managed by mise (configured in sdk.zsh)
# mise provides unified version management for Java, Node.js, Python, etc.
# SDKMAN! has been replaced by mise as of 2025年12月

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -s "$HOME/.deno/env" ] && . "$HOME/.deno/env"

[ -s "$HOME/.moon/bin/env" ] && . "$HOME/.moon/bin/env"
