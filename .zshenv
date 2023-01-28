setopt combiningchars
setopt no_global_rcs

export ZDOTDIR=$HOME/.config/zsh
export ZRCDIR=$ZDOTDIR/zshrc

export ANYENV_ROOT="$HOME/.anyenv"
export NVM_DIR="$HOME/.nvm"

if [ -d "$HOME/AndroidTools" ] ; then
  export ANDROID_HOME=$HOME/AndroidTools
  export ANDROID_SDK_ROOT=$ANDROID_HOME/sdk
fi

if [ -d "$HOME/Library/Android" ] ; then
  export ANDROID_HOME=$HOME/Library/Android
  export ANDROID_SDK_ROOT=$ANDROID_HOME/sdk
fi

[ -f $ZDOTDIR/zshenv/`uname`.zsh ] && . $ZDOTDIR/zshenv/`uname`.zsh
[ -f $HOME/.zshenv_local ] && . $HOME/.zshenv_local
