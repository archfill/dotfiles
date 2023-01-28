source "$ZRCDIR/base.zsh"
source "$ZRCDIR/options.zsh"
source "$ZRCDIR/functions.zsh"
source "$ZRCDIR/alias.zsh"
source "$ZRCDIR/bindkey.zsh"
source "$ZRCDIR/plugins.zsh"

[ -f $ZRCDIR/`uname`/base.zsh ] && . $ZRCDIR/`uname`/base.zsh
[ -f $ZRCDIR/`uname`/options.zsh ] && . $ZRCDIR/`uname`/options.zsh
[ -f $ZRCDIR/`uname`/functions.zsh ] && . $ZRCDIR/`uname`/functions.zsh
[ -f $ZRCDIR/`uname`/alias.zsh ] && . $ZRCDIR/`uname`/alias.zsh
[ -f $ZRCDIR/`uname`/bindkey.zsh ] && . $ZRCDIR/`uname`/bindkey.zsh
[ -f $ZRCDIR/`uname`/plugins.zsh ] && . $ZRCDIR/`uname`/plugins.zsh

[ -f $HOME/zshrc_local.zsh ] && . $HOME/zshrc_local.zsh
