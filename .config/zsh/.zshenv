# ZDOTDIR can be inherited before zsh reads ~/.zshenv. Load the canonical
# environment file in that case so non-login shells get the same setup.
if [[ -f "$HOME/.zshenv" ]]; then
  source "$HOME/.zshenv"
fi
