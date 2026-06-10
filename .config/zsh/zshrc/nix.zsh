# Nix package manager — force PATH precedence
#
# nix-daemon.sh は /etc/zshrc から source されるが、その後 tools.zsh や
# sdk.zsh (mise activate) などで opencode / mise などが PATH 先頭に
# prepend されるため、Nix profile が中盤〜末尾に押し下げられる。
# ここで明示的に Nix path を **先頭に再配置** することで、Nix で管理する
# binary が Homebrew より優先されるようにする。
#
# Nix 未インストール環境では何もしない。

# nix-darwin per-user > home-manager .nix-profile > Determinate global の順で
# 先頭に再配置する。配列の後ろから前へ順に挿入することで、最終的な優先順位は
# nix-darwin per-user が最優先になる。
for _nix_bin in \
  "/nix/var/nix/profiles/default/bin" \
  "$HOME/.nix-profile/bin" \
  "/etc/profiles/per-user/$USER/bin"; do
  if [[ -d "$_nix_bin" ]]; then
    path=("$_nix_bin" "${(@)path:#$_nix_bin}")
  fi
done
unset _nix_bin

export PATH
