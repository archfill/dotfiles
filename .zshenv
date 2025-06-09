setopt combiningchars
setopt no_global_rcs

export ZDOTDIR=$HOME/.config/zsh
export ZRCDIR=$ZDOTDIR/zshrc

# Modern package managers are used instead:
# - uv for Python (replaces pyenv)
# - volta for Node.js (replaces nvm)

# Android SDK configuration - unified for all platforms
setup_android_sdk() {
  local android_home="$1"
  if [ -d "$android_home" ]; then
    export ANDROID_HOME="$android_home"
    export ANDROID_SDK_ROOT="$ANDROID_HOME/sdk"
    return 0
  fi
  return 1
}

# Try different Android SDK locations
setup_android_sdk "$HOME/AndroidTools" || \
setup_android_sdk "$HOME/Library/Android" || \
setup_android_sdk "$HOME/Android/Sdk"  # Common Linux location

if [ -f "$ZDOTDIR/zshenv/`uname`/init.zsh" ]; then . "$ZDOTDIR/zshenv/`uname`/init.zsh"; fi
if [ -f "$HOME/zshenv_local.zsh" ]; then . "$HOME/zshenv_local.zsh"; fi
