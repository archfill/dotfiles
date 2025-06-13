# keyconfig
## disable
bindkey -r '^J'

# 補完機能を有効にする
bindkey "\e[Z" reverse-menu-complete

# Select history with fzf
zle -N select-history
bindkey '^r' select-history

# ghq project selection
function ghq-project-selection() {
  if command -v ghq >/dev/null 2>&1; then
    g
  else
    echo "ghq is not installed. Run 'make install' or install ghq manually."
  fi
}
zle -N ghq-project-selection
bindkey '^g' ghq-project-selection

# Quick directory navigation
function dotfiles-cd() {
  cd ~/dotfiles
  zle reset-prompt
}
zle -N dotfiles-cd
bindkey '^d' dotfiles-cd
