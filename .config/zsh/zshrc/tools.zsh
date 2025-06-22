# Modern CLI tools configuration

# Zoxide - smart cd command
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # Alias cd to z for compatibility
  alias cd='z'
fi

# Eza - modern ls replacement
if command -v eza &> /dev/null; then
  alias ls='eza --color=auto --group-directories-first'
  alias ll='eza -l --color=auto --group-directories-first'
  alias la='eza -la --color=auto --group-directories-first'
  alias lt='eza --tree --color=auto --group-directories-first'
  alias l='eza --color=auto --group-directories-first'
fi

# Bat - modern cat replacement
if command -v bat &> /dev/null; then
  alias cat='bat --style=auto'
  alias bathelp='bat --help'
  export BAT_THEME="tokyonight_night"
fi

# fzf-tab configuration
if [[ -n "$ZSH_VERSION" ]]; then
  # Enable fzf-tab
  zstyle ':fzf-tab:complete:*' fzf-preview 'echo $desc'
  
  # Use eza for file previews if available
  if command -v eza &> /dev/null; then
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || echo $desc'
  fi
  
  # Use bat for file content previews if available
  if command -v bat &> /dev/null; then
    zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
      fzf-preview 'echo ${(P)word}' 2>/dev/null
    zstyle ':fzf-tab:complete:*:options' fzf-preview 
    zstyle ':fzf-tab:complete:*:arguments' fzf-preview
    zstyle ':fzf-tab:complete:(\\|)run-help:*' fzf-preview 'run-help $word' 2>/dev/null
  fi
  
  # Configure fzf-tab appearance
  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  zstyle ':fzf-tab:*' popup-min-size 80 12
fi

# zsh-you-should-use configuration  
export YSU_MESSAGE_POSITION="after"
export YSU_MODE=ALL

# zsh-abbr configuration
if [[ -n "$ZSH_VERSION" ]] && command -v abbr &> /dev/null; then
  # Set abbr scope to user
  export ABBR_USER_ABBREVIATIONS_FILE="$HOME/.config/zsh/abbreviations"
  
  # Create abbreviations file if it doesn't exist
  if [[ ! -f "$ABBR_USER_ABBREVIATIONS_FILE" ]]; then
    mkdir -p "$(dirname "$ABBR_USER_ABBREVIATIONS_FILE")"
    touch "$ABBR_USER_ABBREVIATIONS_FILE"
  fi
fi