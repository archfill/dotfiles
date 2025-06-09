if [ -d "/home/linuxbrew" ] ; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# uv
export PATH="$HOME/.cargo/bin:$PATH"
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

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
