
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

# ghq のリポジトリを「表示名<TAB>パス」で出す。表示名は ~ 始まり (~/git/kotorae, ~/dotfiles)。
# ghq は主 root の symlink を解決して返すので、主 root 配下は設定上のパス (~/git) に戻す。
function _ghq_candidates() {
  ghq list --full-path | awk -v rs="$(ghq root)/" -v lr="$(_ghq_primary_root)/" \
    -v h="$HOME/" -v OFS="\t" '{
    p = $0
    if (index(p, rs) == 1) p = lr substr(p, length(rs) + 1)
    l = p
    if (index(l, h) == 1) l = "~/" substr(l, length(h) + 1)
    print l, p
  }'
}

# 主 root の設定値 (symlink を解決しない)。ghq は最後の ghq.root を主 root にする
function _ghq_primary_root() {
  git config --path --get-all ghq.root | tail -n 1
}

# ghq-based project selection
function g() {
  local src=$(_ghq_candidates | fzf \
    --delimiter="\t" \
    --with-nth=1 \
    --height=50% \
    --layout=reverse \
    --border \
    --prompt="Project > " | cut -f2
  )
  
  if [[ -n "$src" ]]; then
    local repo_path="$src"
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

function gq() {
  local repo_path
  repo_path=$(_ghq_candidates | fzf --delimiter="\t" --with-nth=1 | cut -f2)
  [[ -n "$repo_path" ]] && cd "$repo_path" && exec "$SHELL"
}

# 削除候補は主 root (ghq get の clone 先) 配下だけ。追加 root の ~/harness-configs は実体なので出さない
function ghq-remove() {
  _ghq_candidates | awk -F "\t" -v rs="$(_ghq_primary_root)/" 'index($2, rs) == 1' |
    fzf --multi --delimiter="\t" --with-nth=1 | cut -f2 | xargs -I {} rm -rf {}
}

function ghq-clone() {
  ghq-get "$@"
  return "$?"
}

vibe() { eval "$(command vibe "$@")" }
