# ===== IMPORTANT NOTE =====
# Environment variables and PATH settings have been moved to .zshenv
# to ensure they are available in all shell types (login, non-login, interactive, non-interactive).
# This fixes issues with VSCode and other tools that spawn non-login shells.
#
# See:
# - ~/.zshenv (common settings)
# - ~/.config/zsh/zshenv/{Linux,Darwin,WSL}/init.zsh (platform-specific settings)
#
# This file (.zprofile) is now reserved for:
# - Interactive completion setup
# - Time-consuming initialization that should only run once at login
# - Special login-only configurations

# Load performance optimization library if not already loaded
# Note: This should already be loaded from .zshenv, but we check just in case
if ! command -v command_exists &>/dev/null; then
  if [[ -f "${ZDOTDIR}/lib/performance.zsh" ]]; then
    source "${ZDOTDIR}/lib/performance.zsh"
  else
    # Fallback functions if performance library fails to load
    command_exists() { command -v "$1" &>/dev/null; }
    dir_exists() { [[ -d "$1" ]]; }
    add_to_path() {
      local new_path="$1"
      local position="${2:-front}"
      [[ -d "$new_path" ]] || return 1
      [[ ":$PATH:" == *":$new_path:"* ]] && return 0
      if [[ "$position" == "back" ]]; then
        export PATH="$PATH:$new_path"
      else
        export PATH="$new_path:$PATH"
      fi
    }
    source_if_exists() { [[ -f "$1" ]] && source "$1"; }
    init_env_var() { [[ -z "${(P)1}" ]] && export "$1"="$2"; }
    exec_if_command() {
      local cmd="$1"
      shift
      command_exists "$cmd" || return 1
      eval "$@"
    }
  fi
fi

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi


# Google Cloud SDK configuration - optimized with caching
setup_google_cloud_sdk() {
  local gcloud_path="$1"
  
  # Early return if directory doesn't exist
  dir_exists "$gcloud_path" || return 1
  
  # Source configuration files (non-blocking)
  source_if_exists "$gcloud_path/path.zsh.inc"
  source_if_exists "$gcloud_path/completion.zsh.inc"
  return 0
}

# Try different Google Cloud SDK locations (short-circuit evaluation)
setup_google_cloud_sdk "$HOME/google-cloud-sdk" || \
setup_google_cloud_sdk "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" || \
setup_google_cloud_sdk "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" || \
setup_google_cloud_sdk "/snap/google-cloud-sdk/current" || true

# ===== Go, Rust, Deno, Bun Environment Setup =====
# MOVED TO: ~/.zshenv
# These environment variables are now set in .zshenv to ensure they are available
# in all shell types (including non-login shells like VSCode terminals)

# ===== Interactive Completions =====
# These should ideally be in .zshrc (for interactive shells only)
# but are kept here for backwards compatibility

# fzf integration - Nix (home-manager) provided shell scripts.
# Brew 時代は ~/.fzf.zsh を生成して source していたが、Nix 移管に伴い
# home-manager の share/fzf/ から直接 source する形に変更した。
# nix-darwin 経由では /etc/profiles/per-user/<user>/、home-manager 単体は
# ~/.nix-profile/ に配置される。両対応のため両方試行する (source_if_exists
# が no-op で安全)。
for _hm_dir in "/etc/profiles/per-user/$USER" "$HOME/.nix-profile"; do
  source_if_exists "$_hm_dir/share/fzf/completion.zsh"
  source_if_exists "$_hm_dir/share/fzf/key-bindings.zsh"
done
unset _hm_dir

# uv - unified Python package manager completion
if command_exists uv; then
  eval "$(uv generate-shell-completion zsh)" 2>/dev/null || true
fi

# kubectl completion - conditional with error handling
exec_if_command kubectl '[[ "$commands[kubectl]" ]] && source <(kubectl completion zsh)' 2>/dev/null || true

# helm completion - conditional with error handling
exec_if_command helm '[[ "$commands[helm]" ]] && source <(helm completion zsh)' 2>/dev/null || true

# Platform-specific initialization - optimized
source_if_exists "$ZDOTDIR/zprofile/$(uname)/init.zsh"

# vendor_perl PATH - optimized
[[ -f "/usr/bin/vendor_perl/po4a" ]] && add_to_path "/usr/bin/vendor_perl"

# Flutter configuration moved to sdk.zsh to avoid duplication

# ===== Nix home-manager session variables =====
# JAVA_HOME 等 Nix の home.sessionVariables で宣言した変数を全 shell で
# 利用可能にする。.zshenv では setopt no_global_rcs が効かず
# /etc/zprofile の path_helper が PATH を書き換えてしまうため、本ファイル
# (path_helper の後で読まれる .zprofile) で対処する。
# nix-darwin 経由と home-manager 単体で配置先が異なるため両対応。
source_if_exists "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
source_if_exists "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

# ===== Nix path precedence (login shell / non-interactive 用) =====
# /etc/zprofile の path_helper が PATH 先頭を /etc/paths で上書きするため、
# その直後である本ファイルで Nix path を強制的に先頭へ再配置する。
# interactive shell では .zshrc 経由で nix.zsh が同じ処理を再実行する
# (二重実行は idempotent なので問題なし)。これにより claude-mem の
# Stop hook のような login かつ non-interactive な文脈でも、Nix 経由の
# 言語ランタイム (java / node / python / go / bun / deno 等) が確実に
# 解決される。
# 配列の後ろから前へ順に挿入することで、最終的な優先順位は
# nix-darwin per-user > home-manager .nix-profile > Determinate global
# の並びになる。
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

# Keep project-specific mise tools ahead of the Nix fallback after
# /etc/zprofile/path_helper and the Nix profile have modified PATH.
if command_exists mise; then
  eval "$(mise activate zsh --shims)" 2>/dev/null || true
fi

