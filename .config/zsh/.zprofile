# 補完機能を有効にする
autoload -Uz compinit && compinit -u
autoload bashcompinit && bashcompinit

export PATH=${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
export PATH=$HOME/.local/bin:$PATH

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi

# Node.js version management - modern approach with volta
# Priority order: volta (preferred) > nodebrew > nvm (legacy)
setup_nodejs_manager() {
  # 1. Volta (preferred) - fast, reliable, cross-platform
  if [ -d "$HOME/.volta" ]; then
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    
    # Add volta completion if available
    if [[ -f ~/.config/zsh/completions/_volta ]]; then
      fpath+=(~/.config/zsh/completions)
    fi
    return 0
  fi
  
  # 2. Nodebrew (macOS alternative)
  if [ -d "$HOME/.nodebrew/current/bin" ]; then
    export PATH="$HOME/.nodebrew/current/bin:$PATH"
    return 0
  fi
  
  # 3. nvm (legacy fallback - slow startup)
  if [ -d "${NVM_DIR:-$HOME/.nvm}" ]; then
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    return 0
  fi
  
  return 1
}

# Initialize Node.js version manager
setup_nodejs_manager

# anyenv removed - using modern tools instead:
# - uv for Python package management
# - volta for Node.js version management

# Google Cloud SDK configuration - unified for all platforms
setup_google_cloud_sdk() {
  local gcloud_path="$1"
  if [ -d "$gcloud_path" ]; then
    [ -f "$gcloud_path/path.zsh.inc" ] && source "$gcloud_path/path.zsh.inc"
    [ -f "$gcloud_path/completion.zsh.inc" ] && source "$gcloud_path/completion.zsh.inc"
    return 0
  fi
  return 1
}

# Try different Google Cloud SDK locations
setup_google_cloud_sdk "$HOME/google-cloud-sdk" || \
setup_google_cloud_sdk "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" || \
setup_google_cloud_sdk "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" || \
setup_google_cloud_sdk "/snap/google-cloud-sdk/current"  # Snap package location

# opam configuration
if [ -d "${HOME}/.opam" ] ; then
  test -r ${HOME}/.opam/opam-init/init.zsh && . ${HOME}/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
  eval $(opam env)
fi

# golang
if [ -d "$PATH:/usr/local/go/bin" ] ; then
  export PATH=$PATH:/usr/local/go/bin
else
  export GOPATH=$HOME/go;
  export PATH=$PATH:$GOPATH/bin;
fi

# rust cargo
if [ -d "$HOME/.cargo" ] ; then
  source $HOME/.cargo/env
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# uv - unified Python package manager (shared across all platforms)
export PATH="$HOME/.cargo/bin:$PATH"
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

# kubectl completion
which kubectl > /dev/null 2>&1
ERRCHK=$?
if [[ $ERRCHK -eq 0 ]]; then
  [[ $commands[kubectl] ]] && source <(kubectl completion zsh)
fi

# helm completion
which helm > /dev/null 2>&1
ERRCHK=$?
if [[ $ERRCHK -eq 0 ]]; then
  [[ $commands[helm] ]] && source <(helm completion zsh)
fi

[ -f $ZDOTDIR/zprofile/`uname`/init.zsh ] && . $ZDOTDIR/zprofile/`uname`/init.zsh

if [ -f "/usr/bin/vendor_perl/po4a" ] ; then
  export PATH=/usr/bin/vendor_perl:$PATH
fi

# Flutter development environment - unified for all platforms
setup_flutter_environment() {
  # Flutter pub global packages path
  if [ -d "$HOME/.pub-cache/bin" ]; then
    export PATH="$PATH:$HOME/.pub-cache/bin"
  fi
  
  # FVM (Flutter Version Management) global path
  if [ -d "$HOME/fvm/default/bin" ]; then
    export PATH="$PATH:$HOME/fvm/default/bin"
  fi
  
  # Try different Flutter installation locations
  local flutter_paths=(
    "$HOME/development/flutter/bin"        # Manual installation
    "/opt/homebrew/bin/flutter"            # Homebrew Apple Silicon
    "/usr/local/bin/flutter"               # Homebrew Intel
    "/snap/flutter/current/bin"            # Snap package
    "/usr/local/flutter/bin"               # System-wide installation
  )
  
  for flutter_path in "${flutter_paths[@]}"; do
    local flutter_dir="$(dirname "$flutter_path")"
    if [ -d "$flutter_dir" ] && [ -x "$flutter_path" ]; then
      export PATH="$flutter_dir:$PATH"
      
      # Set FLUTTER_ROOT if not already set
      if [ -z "${FLUTTER_ROOT:-}" ]; then
        export FLUTTER_ROOT="$(dirname "$flutter_dir")"
      fi
      
      return 0
    fi
  done
  
  return 1
}

# Initialize Flutter environment
setup_flutter_environment

