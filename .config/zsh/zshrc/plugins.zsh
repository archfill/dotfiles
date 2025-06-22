### Sheldon - Modern zsh plugin manager
# Dynamic path detection for sheldon
setup_sheldon() {
  local sheldon_paths=(
    "$HOME/.local/bin/sheldon"    # Local installation
    "/usr/local/bin/sheldon"      # System installation
    "/usr/bin/sheldon"            # Package manager installation
  )
  
  for sheldon_path in "${sheldon_paths[@]}"; do
    if [ -f "$sheldon_path" ] && [ -x "$sheldon_path" ]; then
      # Load sheldon plugins
      eval "$($sheldon_path source)"
      return 0
    fi
  done
  
  echo "Warning: sheldon not found in any expected location"
  return 1
}

# Load sheldon if available
if setup_sheldon; then
  # Sheldon will handle all plugin loading via plugins.toml
  true
else
  echo "Note: sheldon not available, using basic zsh without plugins"
fi

### Starship - Cross-shell prompt
# Dynamic path detection for starship
setup_starship() {
  local starship_paths=(
    "$HOME/.local/bin/starship"   # Local installation
    "/usr/local/bin/starship"     # System installation
    "/usr/bin/starship"           # Package manager installation
  )
  
  for starship_path in "${starship_paths[@]}"; do
    if [ -f "$starship_path" ] && [ -x "$starship_path" ]; then
      # Initialize starship prompt
      eval "$($starship_path init zsh)"
      return 0
    fi
  done
  
  echo "Warning: starship not found in any expected location"
  return 1
}

# Load starship if available, otherwise fall back to basic prompt
if ! setup_starship; then
  echo "Note: starship not available, using basic zsh prompt"
  # Basic fallback prompt
  PROMPT='%F{cyan}%~%f %F{purple}❯%f '
fi