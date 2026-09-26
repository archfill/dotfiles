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
# Basic commands
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gl='git pull'
alias gf='git fetch'

# Branch operations
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gsw='git switch'
alias gswc='git switch -c'
alias gco='git checkout'
alias gcb='git checkout -b'

# Diff and log
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'

# Stash operations
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# Merge and rebase
alias gm='git merge'
alias gr='git rebase'
alias gri='git rebase -i'

# Remote operations
alias gre='git remote'
alias grev='git remote -v'

# Combined operations
alias gacp='(){git add . && git commit -m "$1" && git push origin $(git_current_branch)}'
## tmux
alias tmux-start='tmux -u attach -t main'

## Python/uv aliases
# Disabled to use mise's Python directly
# alias python='uv run python'
# alias pip='uv pip'
alias pyproject-init='uv init'

## mise aliases
alias mup='mise install'             # Install all tools from config
alias mls='mise ls'                  # List installed tools
alias muse='mise use'                # Install and pin tool version
alias mex='mise exec'                # Execute command with specific tool
alias menv='mise env'                # Show environment variables
alias mdoc='mise doctor'             # Check mise installation
alias mwatch='mise watch'            # Watch for config changes
alias mtasks='mise tasks'            # List available tasks
alias mrun='mise run'                # Run task from config

## npm aliases
alias gemini-install='npm install -g @google/gemini-cli'

## Claude Code utilities
alias cpclaudemd='cp -i ~/git/claude-configs/templates/CLAUDE-workflow.md ./CLAUDE.md'

## ghq aliases
alias ghq-list='ghq list'
alias ghq-root='ghq root'
alias ghq-look='ghq look'
alias ghq-update='ghq list --full-path | xargs -I {} git -C {} pull'
alias git-health='$HOME/dotfiles/bin/git-health.sh'

## Project navigation shortcuts
alias p='g'  # Short alias for project selection
alias repo='g'  # Alternative alias

## Claude memory plugin
if [[ -f "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs" ]]; then
  alias claude-mem='bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
fi

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
