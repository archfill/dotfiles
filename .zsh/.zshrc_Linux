export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

if [ -d "$HOME/.pyenv" ] ; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if [ -d "/home/linuxbrew" ] ; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

fvim() {
  files=$(git ls-files) &&
  selected_files=$(echo "$files" | fzf -m --preview 'head -100 {}') &&
  vim $selected_files
}

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi

if [ -d "$HOME/.cargo" ] ; then
  source $HOME/.cargo/env
fi

alias wolmac="wakeonlan 14:98:77:6b:00:00"
alias wol2mac="wol 14:98:77:6b:00:00"
## feh
alias sbg-home="sh ~/bin/wallpaper-home.sh"
alias sbg-work="sh ~/bin/wallpaper-work.sh"
## google-drive-ocamlfuse 
alias gdmount='google-drive-ocamlfuse ~/gdchillda'
## mount
alias smbmount='(){sudo mount -t cifs -o username=$1,password=$2,domain=$3 $4 $5}'

if [ -d "$HOME/.deno" ] ; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi

if [ -d "/snap/bin" ] ; then
  export PATH="/snap/bin:$PATH"
fi

export LANG=ja_JP.UTF-8
