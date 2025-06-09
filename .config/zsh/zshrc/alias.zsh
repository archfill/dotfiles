alias ls="ls -G"
alias la="ls -a"
alias ll="ls -lh"

alias vi="nvim"
alias vim="nvim"
# alias tmux="tmux -u"
alias xdisplay="Xephyr -resizeable"
## git
alias gacp='(){git add . && git commit -m "$1" && git push origin $(git_current_branch)}'
## mutt
alias mutt="neomutt"
## tmux
alias tmux-start='tmux -u attach -t main'

# function nvimvenvを呼び出し
alias nvim=nvimvenv

## Python/uv aliases
alias python='uv run python'
alias pip='uv pip'
alias pyproject-init='uv init'
alias pyenv-install='uv python install'
alias pyenv-versions='uv python list'
alias pyenv-which='uv python which'
