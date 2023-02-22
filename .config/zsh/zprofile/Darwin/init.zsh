# homebrew
## m1
if [ -d "/opt/homebrew/bin" ] ; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

## intel
if [ -e "/usr/local/bin/brew" ] ; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

which fnm > /dev/null 2>&1
ERRCHK=$?
if [[ $ERRCHK -eq 0 ]]; then
  eval "$(fnm env --use-on-cd)"
fi

# java
# if [ `/usr/libexec/java_home` ] ; then
# export JAVA_HOME=`/usr/libexec/java_home`
# PATH=${JAVA_HOME}/bin:${PATH}
# fi
if [ `/usr/libexec/java_home -v "11"` ] ; then
  export JAVA_HOME=`/usr/libexec/java_home -v "11"`
  export PATH=${JAVA_HOME}/bin:${PATH}
fi

if [ -d "$HOME/.jenv/bin" ] ; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# flutter
export PATH="$PATH:$FLUTTER_ROOT/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# direnv
eval "$(direnv hook zsh)"

# google-cloud-sdk
## m1
if [ -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ] ; then
  source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

## intel
if [ -d "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ] ; then
  source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

# mysql-client
## m1
if [ -d "/opt/homebrew/opt/mysql-client/bin" ] ; then
  export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
fi

# skhd startup
# isskhd=(`ps aux | grep skhd | awk '{print $11}'`)
# if [[ "$isskhd" != *skhd* ]]; then
#   nohup skhd &
# fi
