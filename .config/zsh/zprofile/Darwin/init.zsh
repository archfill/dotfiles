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

# Java configuration - removed default version, keeping specific version only
# Default Java setup removed to avoid conflicts with jenv
if [ `/usr/libexec/java_home -v "11"` ] ; then
  export JAVA_HOME=`/usr/libexec/java_home -v "11"`
  export PATH=${JAVA_HOME}/bin:${PATH}
fi

if [ -d "$HOME/.jenv/bin" ] ; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# uv configuration moved to shared .zprofile
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Flutter configuration moved to shared configuration
# Individual FLUTTER_ROOT should be set in personal.conf if needed

# direnv
eval "$(direnv hook zsh)"

# Google Cloud SDK configuration moved to shared .zprofile to avoid duplication

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
