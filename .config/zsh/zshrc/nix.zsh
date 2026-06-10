# Nix package manager — force PATH precedence
#
# nix-daemon.sh は /etc/zshrc から source されるが、その後 tools.zsh や
# sdk.zsh (mise activate) などで opencode / mise などが PATH 先頭に
# prepend されるため、Nix profile が中盤〜末尾に押し下げられる。
# ここで明示的に Nix path を **先頭に再配置** することで、Nix で管理する
# binary が Homebrew より優先されるようにする。
#
# Nix 未インストール環境では何もしない。

if [[ -d "$HOME/.nix-profile/bin" ]]; then
  path=("$HOME/.nix-profile/bin" "${(@)path:#$HOME/.nix-profile/bin}")
fi

if [[ -d "/nix/var/nix/profiles/default/bin" ]]; then
  path=("/nix/var/nix/profiles/default/bin" "${(@)path:#/nix/var/nix/profiles/default/bin}")
fi

export PATH
