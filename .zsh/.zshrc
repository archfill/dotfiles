# zplug
source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# theme (https://github.com/sindresorhus/pure#zplug)　好みのスキーマをいれてくだされ。
zplug "mafredri/zsh-async"
zplug "sindresorhus/pure"

# ZSH_THEME="powerlevel9k/powerlevel9k"
ZSH_THEME="agnoster"
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting"
# history関係
zplug "zsh-users/zsh-history-substring-search"
# タイプ補完
zplug "zsh-users/zsh-autosuggestions", lazy:true
zplug "zsh-users/zsh-completions", lazy:true
zplug "chrissicool/zsh-256color", lazy:true
zplug "docker/cli", use:"contrib/completion/zsh/_docker", lazy:true
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# Then, source plugins and add commands to $PATH
zplug load

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
alias dc-mysql57-up-d="sudo docker-compose -f ~/docker/mysql57/docker-compose.yml up -d"
alias dc-mysql57-down="sudo docker-compose -f ~/docker/mysql57/docker-compose.yml down"
alias dcompose="sudo docker-compose"
alias xdisplay="Xephyr -resizeable"
alias wolhome="wol d0:50:99:8c:84:1d"
## git
alias gacp='(){git add . && git commit -m "$1" && git push origin $(git_current_branch)}'
## mutt
alias mutt="neomutt"
## feh
alias sbg-home="sh ~/bin/wallpaper-home.sh"
alias sbg-work="sh ~/bin/wallpaper-work.sh"
## google-drive-ocamlfuse 
alias gdmount='google-drive-ocamlfuse ~/gdchillda'

## mount
alias smbmount='(){sudo mount -t cifs -o username=$1,password=$2,domain=$3 $4 $5}'

## tmux
alias tmux-start='tmux -u attach -t main'

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/chillda/google-cloud-sdk/path.zsh.inc' ]; then . '/home/chillda/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/chillda/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/chillda/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$HOME/.anyenv/bin:$PATH"
export ANYENV_ROOT="$HOME/.anyenv"
eval "$(anyenv init - zsh)"

[ -f $ZDOTDIR/.zshrc_`uname` ] && . $ZDOTDIR/.zshrc_`uname`

# opam configuration
test -r /home/chillda/.opam/opam-init/init.zsh && . /home/chillda/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
eval $(opam env)

export LANG=ja_JP.UTF-8
export ANDROID_HOME=$HOME/AndroidTools
export ANDROID_SDK_ROOT=$ANDROID_HOME/sdk
# golang
export PATH=$PATH:/usr/local/go/bin

function precmd() {
  if [ ! -z $TMUX ]; then
    tmux refresh-client -S
  fi
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
