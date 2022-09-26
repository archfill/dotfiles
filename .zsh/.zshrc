### Zinit
source "$HOME/.zinit/bin/zinit.zsh"
zinit self-update
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
#zinit light-mode for \
#    zinit-zsh/z-a-rust \
#    zinit-zsh/z-a-as-monitor \
#    zinit-zsh/z-a-patch-dl \
#    zinit-zsh/z-a-bin-gem-node

zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light chrissicool/zsh-256color
zinit lucid has'docker' for \
  as'completion' is-snippet \
  'https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker' \
  \
  as'completion' is-snippet \
  'https://github.com/docker/compose/blob/master/contrib/completion/zsh/_docker-compose' \

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 補完機能を有効にする
autoload -Uz compinit && compinit -u
bindkey "\e[Z" reverse-menu-complete

# 補完候補を一覧を表示
setopt auto_list

# 補完メニューをカーソルで選択可能にする
zstyle ':completion:*:default' menu select=2

alias ls="ls -G"
alias la="ls -a"
alias ll="ls -lh"

alias vi="nvim"
alias vim="nvim"
alias tmux="tmux -u"
alias xdisplay="Xephyr -resizeable"
## git
alias gacp='(){git add . && git commit -m "$1" && git push origin $(git_current_branch)}'
## mutt
alias mutt="neomutt"
## tmux
alias tmux-start='tmux -u attach -t main'

function nvimvenv {
  if [[ -e "$VIRTUAL_ENV" && -f "$VIRTUAL_ENV/bin/activate" ]]; then
    source "$VIRTUAL_ENV/bin/activate"
    command nvim $@
    deactivate
  else
    command nvim $@
  fi
}

alias nvim=nvimvenv

if [ -d "$HOME/google-cloud-sdk" ] ; then
  # The next line updates PATH for the Google Cloud SDK.
  source "$HOME/google-cloud-sdk/path.zsh.inc"
  # The next line enables bash completion for gcloud.
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

if [ -d "$HOME/.nodebrew/current/bin" ] ; then
  echo "Directory .nodebrew/current/bin exists."
  export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

if [ -d "$HOME/.nvm" ] ; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

export PATH="$HOME/.anyenv/bin:$PATH"
export ANYENV_ROOT="$HOME/.anyenv"
eval "$(anyenv init - zsh)"

[ -f $ZDOTDIR/.zshrc_`uname` ] && . $ZDOTDIR/.zshrc_`uname`

# opam configuration
if [ -d "${HOME}/.opam" ] ; then
  test -r ${HOME}/.opam/opam-init/init.zsh && . ${HOME}/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
  eval $(opam env)
fi

if [ -d "$HOME/AndroidTools" ] ; then
  export ANDROID_HOME=$HOME/AndroidTools
  export ANDROID_SDK_ROOT=$ANDROID_HOME/sdk
fi

if [ -d "$HOME/Library/Android" ] ; then
  export ANDROID_HOME=$HOME/Library/Android
  export ANDROID_SDK_ROOT=$ANDROID_HOME/sdk
fi

# golang
if [ -d "$PATH:/usr/local/go/bin" ] ; then
  export PATH=$PATH:/usr/local/go/bin
else
  export GOPATH=$HOME/go;
  export PATH=$PATH:$GOPATH/bin;
fi

function precmd() {
  if [ ! -z $TMUX ]; then
    tmux refresh-client -S
  fi
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi

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

echo '' > /dev/null 2>&1
