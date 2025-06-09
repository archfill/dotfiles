### Zinit - Dynamic path detection
# Try different zinit installation locations
setup_zinit() {
  local zinit_paths=(
    "$HOME/.local/share/zinit/zinit.git/zinit.zsh"  # Modern installation
    "$HOME/.zinit/zinit.zsh"                        # Legacy installation  
    "$HOME/.zinit/bin/zinit.zsh"                    # Old legacy path
  )
  
  for zinit_path in "${zinit_paths[@]}"; do
    if [ -f "$zinit_path" ]; then
      source "$zinit_path"
      return 0
    fi
  done
  
  echo "Warning: zinit not found in any expected location"
  return 1
}

# Load zinit if available
if setup_zinit; then
  # Initialize zinit
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  # Load a few important annexes, without Turbo
  # (this is currently required for annexes)
  #zinit light-mode for \
  #    zinit-zsh/z-a-rust \
  #    zinit-zsh/z-a-as-monitor \
  #    zinit-zsh/z-a-patch-dl \
  #    zinit-zsh/z-a-bin-gem-node

  # Load prompt theme
  zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
  zinit light sindresorhus/pure

  # Load essential plugins
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-history-substring-search
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-completions
  zinit light chrissicool/zsh-256color
  
  # Docker completions
  zinit lucid has'docker' for \
    as'completion' is-snippet \
    'https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker'

  # zinit lucid has'docker' for \
  #   as'completion' is-snippet \
  #   'https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker' \
  #   \
  #   as'completion' is-snippet \
  #   'https://github.com/docker/compose/blob/master/contrib/completion/zsh/_docker-compose'
else
  echo "Note: zinit not available, using basic zsh without plugins"
fi
