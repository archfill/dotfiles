#!/usr/bin/env bash

set -euo pipefail
trap 'echo "[Error] Command \"$BASH_COMMAND\" failed at line $LINENO"; exit 1' ERR

echo "[Start] WezTerm installation"

# Rustupの確認とインストール
if [ ! -d "${HOME}/.rustup" ]; then
  echo "[Info] Installing Rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "${HOME}/.cargo/env"
fi

echo "[Info] Setting up Rust toolchain..."
rustup override set stable
rustup update stable

echo "[Info] Installing build dependencies..."
sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

echo "[Info] Preparing build directory..."
mkdir -p ~/build
cd ~/build

if [ -d "./wezterm" ]; then
  echo "[Info] Removing existing wezterm directory..."
  rm -rf ./wezterm
fi

echo "[Info] Cloning WezTerm repository..."
git clone --depth=1 --branch=main --recursive https://github.com/wez/wezterm.git
cd wezterm

echo "[Info] Updating submodules..."
git submodule update --init --recursive

echo "[Info] Getting dependencies..."
./get-deps

echo "[Info] Building WezTerm (this may take a while)..."
cargo build --release

echo "[Info] Installing WezTerm binary..."
sudo cp -f target/release/wezterm /usr/local/bin/

echo "[Success] WezTerm installation completed"
echo "[Info] You can now run WezTerm with: wezterm"

cd ~/dotfiles
