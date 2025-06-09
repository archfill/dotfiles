# macOS-specific plugin configurations

# Add Homebrew completions to fpath (Apple Silicon)
if [ -d "/opt/homebrew/share/zsh/site-functions" ]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

# Add Homebrew completions to fpath (Intel)
if [ -d "/usr/local/share/zsh/site-functions" ]; then
  fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# macOS system completions
if [ -d "/usr/share/zsh/site-functions" ]; then
  fpath=(/usr/share/zsh/site-functions $fpath)
fi