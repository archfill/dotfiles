# ls aliases - conditionally use eza or traditional ls  
if command -v eza >/dev/null 2>&1; then
  # Modern eza-based aliases (defined in tools.zsh)
  true  # eza aliases are defined in tools.zsh
else
  # Traditional ls aliases
  alias ls="ls -G"
  alias la="ls -a"
  alias ll="ls -lh"
fi

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

## Flutter development aliases (cross-platform)
alias fl='flutter'
alias flpub='flutter pub'
alias flrun='flutter run'
alias flclean='flutter clean'
alias fldoc='flutter doctor'
alias fltest='flutter test'

# FVM aliases (if FVM is available)
if command -v fvm >/dev/null 2>&1; then
  alias fvmlist='fvm list'
  alias fvmuse='fvm use'
  alias fvminstall='fvm install'
fi

# Platform-specific development tool aliases
case "$(uname)" in
  Darwin)
    # iOS Simulator shortcuts (macOS only)
    alias ios='open -a Simulator'
    alias iphone='xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "iPhone 15 Pro simulator not available"'
    # Android Studio
    alias studio='open -a "Android Studio"'
    ;;
  Linux)
    # Linux Android development
    if command -v android-studio >/dev/null 2>&1; then
      alias studio='android-studio'
    elif [[ -f "/opt/android-studio/bin/studio.sh" ]]; then
      alias studio='/opt/android-studio/bin/studio.sh'
    fi
    ;;
esac

