# Nix package manager — keep Nix fallback precedence
#
# nix-daemon.sh は /etc/zshrc から source される。ここでは Nix profileを
# system/Homebrewより優先するが、project-specificなmise toolより上には置かない。
# .zshrcではこのファイルをmise activationより先にsourceし、Nix管理のNode/pnpmを
# fallbackとして残しつつ、各repositoryのmise.tomlが選択を上書きできる順序にする。
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
