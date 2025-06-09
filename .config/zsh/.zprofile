# 補完機能を有効にする
autoload -Uz compinit && compinit -u
autoload bashcompinit && bashcompinit

export PATH=${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
export PATH=$HOME/.local/bin:$PATH

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi

# Node.js version management - prioritize volta over other tools
if [ -d "$HOME/.volta" ] ; then
  # Volta JavaScript toolchain manager (preferred)
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
  # Add volta completion if available
  if [[ -f ~/.config/zsh/completions/_volta ]]; then
    fpath+=(~/.config/zsh/completions)
  fi
elif [ -d "$HOME/.nodebrew/current/bin" ] ; then
  # Fallback to nodebrew if volta not available
  export PATH=$HOME/.nodebrew/current/bin:$PATH
elif [ -d "$HOME/.nvm" ] ; then
  # Fallback to nvm if neither volta nor nodebrew available
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

if [ -d "$ANYENV_ROOT" ] ; then
  export PATH="$ANYENV_ROOT/bin:$PATH"
  eval "$(anyenv init - zsh)"
fi

if [ -d "$HOME/google-cloud-sdk" ] ; then
  # The next line updates PATH for the Google Cloud SDK.
  source "$HOME/google-cloud-sdk/path.zsh.inc"
  # The next line enables bash completion for gcloud.
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

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

# flutter
export PATH="$PATH:$HOME/.pub-cache/bin"
# fvm global path
if [ -d "$HOME/fvm/default/bin" ] ; then
  export PATH="$PATH:$HOME/fvm/default/bin"
fi

