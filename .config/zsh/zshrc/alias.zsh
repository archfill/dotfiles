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

# function nvimvenvを呼び出し
alias nvim=nvimvenv

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

## Neovim Version Management aliases
# Helper function for Neovim switcher
_nvim_switch() {
    local switcher="${DOTFILES_DIR:-$HOME/dotfiles}/bin/apps/neovim_switcher.sh"
    if [[ -f "$switcher" ]]; then
        bash "$switcher" "$@"
    else
        echo "Error: Neovim switcher not found at $switcher"
        echo "Please check DOTFILES_DIR environment variable or run 'make neovim-setup'"
        return 1
    fi
}

# Neovim management aliases that work from anywhere
alias nvim-s='_nvim_switch s'         # Switch to stable
alias nvim-n='_nvim_switch n'         # Switch to nightly  
alias nvim-t='_nvim_switch t'         # Toggle versions
alias nvim-u='_nvim_switch u'         # Update current version
alias nvim-status='_nvim_switch status'  # Show status
