# Linux-specific plugin configurations

# Load additional Linux-specific completions if available
if [ -d "/usr/share/zsh/site-functions" ]; then
  fpath=(/usr/share/zsh/site-functions $fpath)
fi

if [ -d "/usr/local/share/zsh/site-functions" ]; then
  fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Arch Linux specific completions
if [ -d "/usr/share/zsh/functions/Completion" ]; then
  fpath=(/usr/share/zsh/functions/Completion $fpath)
fi

# Load snap completions if available
if [ -d "/snap/bin" ] && command -v snap >/dev/null 2>&1; then
  fpath=(/snap/bin $fpath)
fi