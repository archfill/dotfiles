# ===== macOS-specific .zprofile Configuration =====
# IMPORTANT: Most environment variables and PATH settings have been moved to
# ~/.config/zsh/zshenv/Darwin/init.zsh to support non-login shells.
#
# This file is now reserved for:
# - Login-only initialization
# - Interactive completions (consider moving to .zshrc)

# iTerm2 shell integration (interactive only)
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Java configuration via SDKMAN (jenv removed)
# SDKMAN is initialized in .zshrc (interactive shells only)
# For non-interactive shells, JAVA_HOME is set by SDKMAN env

# Flutter configuration moved to shared configuration
# Individual FLUTTER_ROOT should be set in personal.conf if needed

# Google Cloud SDK configuration moved to shared .zprofile to avoid duplication

