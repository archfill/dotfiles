# homebrew
## m1
if [ -d "/opt/homebrew/bin" ] ; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else if [ -e "/usr/local/bin/brew" ] ; then
    ## intel
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi


# Volta settings moved to shared .zprofile to avoid duplication

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

# uv
export PATH="$HOME/.cargo/bin:$PATH"
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# flutter
# export PATH="$PATH:$FLUTTER_ROOT/bin"

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
