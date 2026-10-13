#!/usr/bin/env bash

# 新規セットアップの前提条件チェック (make doctor)
#
# dotfiles 適用前に手動で用意すべきものが揃っているかを確認する。
# 何もインストールしない。足りないものは対処方法を表示する。
# macOS 標準の bash 3.2 で動くように書くこと (Nix 導入前に実行されるため)。
#
# 終了コード: ❌ が 1 つでもあれば 1、それ以外は 0

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FAILED=0
WARNED=0
OP_SSH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

ok() {
  printf '\033[32m✅\033[0m %s\n' "$1"
}

ng() {
  printf '\033[31m❌\033[0m %s\n' "$1"
  shift
  for hint in "$@"; do
    printf '   → %s\n' "$hint"
  done
  FAILED=$((FAILED + 1))
}

warn() {
  printf '\033[33m⚠️ \033[0m %s\n' "$1"
  shift
  for hint in "$@"; do
    printf '   → %s\n' "$hint"
  done
  WARNED=$((WARNED + 1))
}

note() {
  printf 'ℹ️  %s\n' "$1"
  shift
  for hint in "$@"; do
    printf '   → %s\n' "$hint"
  done
}

# ─── 個別チェック ────────────────────────────────────────────────────

check_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    ok "Xcode Command Line Tools ($(xcode-select -p))"
  else
    ng "Xcode Command Line Tools not installed" \
      "Homebrew のインストーラーが一緒に入れる (個別に入れる場合: xcode-select --install)"
  fi
}

check_homebrew() {
  # nix-darwin の homebrew モジュールは brew 本体を入れないため事前に必要
  if [[ -x /opt/homebrew/bin/brew ]]; then
    ok "Homebrew (/opt/homebrew)"
  else
    ng "Homebrew not installed" \
      '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  fi
}

check_nix() {
  local nix_bin=""
  if command -v nix >/dev/null 2>&1; then
    nix_bin="$(command -v nix)"
  elif [[ -x /nix/var/nix/profiles/default/bin/nix ]]; then
    nix_bin="/nix/var/nix/profiles/default/bin/nix"
  fi

  if [[ -z "$nix_bin" ]]; then
    ng "Nix not installed" \
      "curl -fsSL https://install.determinate.systems/nix | sh -s -- install" \
      "インストール後はターミナルを開き直す"
    return
  fi

  # modules/darwin-system.nix は Determinate Nix 前提 (nix.enable = false)
  local version
  version="$("$nix_bin" --version 2>/dev/null)"
  if [[ "$version" == *Determinate* ]] || [[ -e /usr/local/bin/determinate-nixd ]]; then
    ok "Nix ($version)"
  else
    warn "Nix is installed but does not look like Determinate Nix ($version)" \
      "nix-darwin 側の nix 管理を無効にしているため Determinate Nix を推奨"
  fi

  if ! command -v nix >/dev/null 2>&1; then
    warn "nix is not on PATH in this shell" "ターミナルを開き直す"
  fi
}

check_1password() {
  if [[ -d /Applications/1Password.app ]]; then
    ok "1Password app"
  else
    ng "1Password not installed" "brew install --cask 1password"
    return
  fi

  local sock="$OP_SSH_SOCK"
  if [[ ! -S "$sock" ]]; then
    ng "1Password SSH agent is not enabled" \
      "1Password > 設定 > 開発者 > 「SSH エージェントを使用」を ON"
    return
  fi

  local keys
  keys="$(SSH_AUTH_SOCK="$sock" ssh-add -l 2>/dev/null)"
  if [[ -n "$keys" ]] && [[ "$keys" != *"no identities"* ]]; then
    ok "1Password SSH agent ($(printf '%s\n' "$keys" | wc -l | tr -d ' ') key(s))"
  else
    warn "1Password SSH agent has no keys" \
      "1Password が起動・ロック解除されているか、SSH 鍵アイテムがあるか確認"
  fi

}

check_ssh_config() {
  # ~/.ssh/config は home-manager が dotfiles/.ssh/config への symlink として配置する。
  # 通常ファイルがあると switch が "is in the way" で止まる
  local cfg="$HOME/.ssh/config"
  if [[ -L "$cfg" ]]; then
    ok "~/.ssh/config is managed by dotfiles"
  elif [[ -e "$cfg" ]]; then
    ng "~/.ssh/config is a regular file (dotfiles will manage it)" \
      "接続先 (Host ブロック) があれば ~/.ssh/config.d/private に移す" \
      "  mkdir -p ~/.ssh/config.d && mv ~/.ssh/config ~/.ssh/config.d/private" \
      "  (Host * / IdentityAgent / OrbStack の Include は dotfiles 側にあるので消してよい)"
  else
    ok "~/.ssh/config not present yet (dotfiles will create it)"
  fi
}

check_github_ssh() {
  # 認証成功時も ssh -T は exit 1 を返すため出力で判定する
  local out
  # ~/.ssh/config が未配置でも確認できるよう、1Password agent を明示する
  out="$(SSH_AUTH_SOCK="$OP_SSH_SOCK" ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com 2>&1)"
  if [[ "$out" == *"successfully authenticated"* ]]; then
    ok "GitHub SSH authentication"
  else
    warn "GitHub SSH authentication failed" \
      "公開鍵を GitHub に登録する (push / 他リポジトリの clone に必要)" \
      "詳細: ssh -T git@github.com"
  fi
}

check_dotfiles_location() {
  # mkOutOfStoreSymlink や MJConfigFile が ~/dotfiles を前提にしている
  if [[ "$DOTFILES_DIR" == "$HOME/dotfiles" ]]; then
    ok "dotfiles location ($DOTFILES_DIR)"
  else
    ng "dotfiles must be cloned to ~/dotfiles (current: $DOTFILES_DIR)" \
      "git clone git@github.com:archfill/dotfiles.git ~/dotfiles"
  fi
}

check_darwin_host() {
  local host flake user expected
  host="$(scutil --get LocalHostName 2>/dev/null)"
  flake="$DOTFILES_DIR/nix/flake.nix"
  user="$(id -un)"

  if ! grep -q "\"$host\" = mkDarwinHost" "$flake"; then
    ng "Host '$host' is not defined in nix/flake.nix darwinConfigurations" \
      "nix/hosts/$host/{darwin,home}.nix を既存ホストからコピーして作成" \
      "nix/flake.nix の darwinConfigurations に \"$host\" を追加 (docs/macos-setup.md 参照)"
    return
  fi

  if [[ ! -f "$DOTFILES_DIR/nix/hosts/$host/darwin.nix" ]] ||
    [[ ! -f "$DOTFILES_DIR/nix/hosts/$host/home.nix" ]]; then
    ng "nix/hosts/$host/{darwin,home}.nix is missing"
    return
  fi

  # "<host>" = mkDarwinHost { ... username = "<user>"; } の username を取り出す
  expected="$(awk -v h="\"$host\" = mkDarwinHost" '
    index($0, h) { found = 1 }
    found && /username *=/ { gsub(/.*username *= *"|".*/, ""); print; exit }
  ' "$flake")"

  if [[ "$expected" == "$user" ]]; then
    ok "Host '$host' defined in flake (user: $user)"
  else
    ng "Host '$host' expects user '$expected' but current user is '$user'" \
      "nix/flake.nix の \"$host\" の username を修正する"
  fi
}

# ─── 実行 ────────────────────────────────────────────────────────────

echo "Dotfiles prerequisites check"
echo "============================"

case "$(uname -s)" in
  Darwin)
    check_clt
    check_homebrew
    check_1password
    check_nix
    check_dotfiles_location
    check_darwin_host
    check_ssh_config
    check_github_ssh
    note "App Management permission cannot be checked automatically" \
      "システム設定 > プライバシーとセキュリティ > アプリケーション管理 でターミナルを ON" \
      "(未許可だと cask の upgrade / --adopt / uninstall が Operation not permitted になる)"
    ;;
  *)
    note "make doctor currently supports macOS only"
    exit 0
    ;;
esac

echo
if [[ "$FAILED" -gt 0 ]]; then
  printf '\033[31m%d error(s)\033[0m, %d warning(s). Fix the errors above before running make init.\n' "$FAILED" "$WARNED"
  exit 1
fi
printf '\033[32mAll required checks passed\033[0m (%d warning(s)).\n' "$WARNED"
