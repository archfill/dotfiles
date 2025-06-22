# History configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Load performance optimization library if not already loaded
if ! command -v command_exists &>/dev/null; then
  if [[ -f "${ZDOTDIR:-$HOME}/.config/zsh/lib/performance.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.config/zsh/lib/performance.zsh"
  else
    # Fallback functions if performance library fails to load
    command_exists() { command -v "$1" &>/dev/null; }
    dir_exists() { [[ -d "$1" ]]; }
    add_to_path() { 
      local new_path="$1"
      local position="${2:-front}"
      [[ -d "$new_path" ]] || return 1
      [[ ":$PATH:" == *":$new_path:"* ]] && return 0
      if [[ "$position" == "back" ]]; then
        export PATH="$PATH:$new_path"
      else
        export PATH="$new_path:$PATH"
      fi
    }
    source_if_exists() { [[ -f "$1" ]] && source "$1"; }
    init_env_var() { [[ -z "${(P)1}" ]] && export "$1"="$2"; }
  fi
fi

# Initialize completion system (optimized)
autoload -Uz compinit

# Smart compinit - only run daily or when needed
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # Skip security check for faster startup
fi

# 補完メニューをカーソルで選択可能にする
zstyle ':completion:*:default' menu select=2

# 補完メッセージを読みやすくする
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# SDK and tools configuration moved to explicit loading in .zshrc
