HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 補完機能を有効にする
autoload -Uz compinit && compinit -u

# 補完メニューをカーソルで選択可能にする
zstyle ':completion:*:default' menu select=2
