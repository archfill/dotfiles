if [ -d "/home/linuxbrew" ] ; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Volta settings moved to shared .zprofile to avoid duplication

# uv configuration moved to shared .zprofile

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi

if [ -d "$HOME/.deno" ] ; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi

if [ -d "/snap/bin" ] ; then
  export PATH="/snap/bin:$PATH"
fi