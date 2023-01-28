source-safe() { if [ -f "$1" ]; then source "$1"; fi }

export PATH=${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$HOME/.local/bin:$PATH

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi

if [ -d "$HOME/.nodebrew/current/bin" ] ; then
  export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

if [ -d "$ANYENV_ROOT" ] ; then
  export PATH="$ANYENV_ROOT/bin:$PATH"
  eval "$(anyenv init - zsh)"
fi

if [ -d "$HOME/.nvm" ] ; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
which kubectl > /dev/null 2>&1 && ERRCHK=$?
if [[ $ERRCHK -eq 0 ]]; then
  [[ $commands[kubectl] ]] && source <(kubectl completion zsh)
fi

# helm completion
which helm > /dev/null 2>&1 && ERRCHK=$?
if [[ $ERRCHK -eq 0 ]]; then
  [[ $commands[helm] ]] && source <(helm completion zsh)
fi

[ -f $ZDOTDIR/zprofile/`uname`/init.zsh ] && . $ZDOTDIR/zprofile/`uname`/init.zsh
