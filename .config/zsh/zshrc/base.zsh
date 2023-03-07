HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 補完機能を有効にする
autoload -Uz compinit && compinit -u
autoload bashcompinit && bashcompinit

# 補完メニューをカーソルで選択可能にする
zstyle ':completion:*:default' menu select=2

# 補完メッセージを読みやすくする
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
