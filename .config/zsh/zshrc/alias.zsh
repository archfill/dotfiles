alias ls="ls -G"
alias la="ls -a"
alias ll="ls -lh"

alias vi="nvim"
alias vim="nvim"
# Removed: tmux unicode support (now default in modern tmux)
# alias tmux="tmux -u"
alias xdisplay="Xephyr -resizeable"
## git
alias gacp='(){git add . && git commit -m "$1" && git push origin $(git_current_branch)}'
## mutt
alias mutt="neomutt"
## tmux
alias tmux-start='tmux -u attach -t main'

## Python/uv aliases
alias python='uv run python'
alias pip='uv pip'
alias pyproject-init='uv init'
alias pyenv-install='uv python install'
alias pyenv-versions='uv python list'
alias pyenv-which='uv python which'

## ghq aliases
alias ghq-list='ghq list'
alias ghq-root='ghq root'
alias ghq-look='ghq look'
alias gq='ghq list | fzf --preview "echo {} && echo && cat $(ghq root)/{}/README.md 2>/dev/null || ls -la $(ghq root)/{}" | xargs -I {} sh -c "cd $(ghq root)/{} && exec $SHELL"'
alias ghq-remove='ghq list | fzf --multi | xargs -I {} rm -rf $(ghq root)/{}'
alias ghq-update='ghq list | xargs -I {} git -C $(ghq root)/{} pull'

## Project navigation shortcuts
alias p='g'  # Short alias for project selection
alias repo='g'  # Alternative alias

