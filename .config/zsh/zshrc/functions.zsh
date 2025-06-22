
function precmd() {
  if [[ -n "$TMUX" ]]; then
    tmux refresh-client -S
  fi
}

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR="$#BUFFER"
  return 0
}

function dotfiles() {
  cd ~/dotfiles
  return 0
}

# ghq-based project selection with enhanced fzf preview
function g() {
  local src=$(ghq list | fzf \
    --height=50% \
    --layout=reverse \
    --border \
    --prompt="Project > " \
    --preview-window="right:60%" \
    --preview="
      local repo_path=\$(ghq root)/{}
      echo \"📁 Repository: {}\"
      echo \"📍 Path: \$repo_path\"
      echo \"\"
      if [[ -f \"\$repo_path/README.md\" ]]; then
        echo \"📄 README.md:\"
        head -10 \"\$repo_path/README.md\" 2>/dev/null | sed 's/^/  /'
      elif [[ -f \"\$repo_path/readme.md\" ]]; then
        echo \"📄 readme.md:\"
        head -10 \"\$repo_path/readme.md\" 2>/dev/null | sed 's/^/  /'
      elif [[ -f \"\$repo_path/package.json\" ]]; then
        echo \"📦 package.json:\"
        cat \"\$repo_path/package.json\" 2>/dev/null | jq -r '.name, .description, .version' 2>/dev/null | sed 's/^/  /' || echo \"  Node.js project\"
      else
        echo \"📂 Directory contents:\"
        ls -la \"\$repo_path\" | head -10 | tail -n+2 | sed 's/^/  /'
      fi
    "
  )
  
  if [[ -n "$src" ]]; then
    local repo_path="$(ghq root)/$src"
    echo "🚀 Changing to: $repo_path"
    cd "$repo_path"
    return 0
  fi
  return 1
}

# Quick ghq operations
function ghq-get() {
  if [[ "$#" -eq 0 ]]; then
    echo "Usage: ghq-get <repository-url>"
    echo "Example: ghq-get github.com/user/repo"
    return 1
  fi
  ghq get "$1" && g
  return 0
}

function ghq-clone() {
  ghq-get "$@"
  return "$?"
}
