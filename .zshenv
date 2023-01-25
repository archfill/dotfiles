setopt combiningchars
setopt no_global_rcs

export PATH=${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$HOME/.local/bin:$PATH
export ZDOTDIR=$HOME/.config/zsh

[ -f $ZDOTDIR/.zshenv_`uname` ] && . $ZDOTDIR/.zshenv_`uname`
[ -f $HOME/.zshenv_local ] && . $HOME/.zshenv_local
