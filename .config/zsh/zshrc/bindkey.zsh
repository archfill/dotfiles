# keyconfig
## disable
bindkey -r '^J'

# 補完機能を有効にする
bindkey "\e[Z" reverse-menu-complete

# Select history with fzf
zle -N select-history
bindkey '^r' select-history
