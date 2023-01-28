source-safe() { if [ -f "$1" ]; then source "$1"; fi }

source "$ZRCDIR/base.zsh"
source "$ZRCDIR/options.zsh"
source "$ZRCDIR/functions.zsh"
source "$ZRCDIR/alias.zsh"
source "$ZRCDIR/bindkey.zsh"
source "$ZRCDIR/plugins.zsh"

source-safe "$ZRCDIR/`uname`/base.zsh"
source-safe "$ZRCDIR/`uname`/options.zsh"
source-safe "$ZRCDIR/`uname`/functions.zsh"
source-safe "$ZRCDIR/`uname`/alias.zsh"
source-safe "$ZRCDIR/`uname`/bindkey.zsh"
source-safe "$ZRCDIR/`uname`/plugins.zsh"

source-safe "$HOME/zshrc_local.zsh"
