HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Initialize completion system
autoload -Uz compinit
compinit

# 補完メニューをカーソルで選択可能にする
zstyle ':completion:*:default' menu select=2

# 補完メッセージを読みやすくする
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# Load modern CLI tools configuration
source "$HOME/.config/zsh/zshrc/tools.zsh"
