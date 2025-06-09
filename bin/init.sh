#!/usr/bin/env bash

set -euo pipefail
trap 'echo "[Error] Command \"$BASH_COMMAND\" failed."; exit 1' ERR

# Set DOTFILES_DIR if not already set
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  DOTFILES_DIR="$HOME/dotfiles"
fi

mkdir -p "$HOME/.config"

echo "[Start] Dotfiles setup at $(date)"

run() {
  bash "$DOTFILES_DIR/$1"
}

echo "[Info] Starting to create symbolic links"
run "bin/link.sh"

OS_NAME="$(uname)"
echo "[Info] Detected OS: $OS_NAME"

case "$OS_NAME" in
  Darwin)
    echo "[OS] macOS setup starting"
    run "bin/mac/link.sh"
    
    # Skip package installation in CI environment
    if [[ "${SKIP_PACKAGE_INSTALL:-}" != "1" ]]; then
      run "bin/mac/brew.sh"
      run "bin/mac/fonts_setup.sh"
    else
      echo "[Info] Skipping package installation (CI environment)"
    fi
    
    run "bin/mac/config.sh"
    ;;

  Linux)
    echo "[OS] Linux setup starting"
    run "bin/linux/install_linux.sh"
    run "bin/linux/apps/fonts_setup.sh"
    run "bin/linux/apps/deno_install.sh"
    run "bin/linux/apps/neovim_install.sh"
    ;;

  MINGW32_NT*|MINGW64_NT*)
    echo "[OS] Windows (Cygwin) setup starting"
    run "bin/cygwin/install_cygwin.sh"
    ;;

  *)
    echo "[Error] Unsupported OS: $OS_NAME"
    exit 1
    ;;
esac

# Skip app setup in CI environment
if [[ "${SKIP_PACKAGE_INSTALL:-}" != "1" ]]; then
  echo "[Info] Starting app setup"
  run "bin/apps_setup.sh"
else
  echo "[Info] Skipping app setup (CI environment)"
fi

echo "[Info] Starting config setup"
run "bin/config.sh"

echo "[Success] Dotfiles setup completed at $(date)"

exit 0
