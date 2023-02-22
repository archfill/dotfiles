#!/bin/bash

if [ ! -e `${HOME}/.rustup` ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

rustup override set stable
rustup update stable

sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

mkdir ~/build
cd ~/build

if [ -e `./alacritty` ]; then
  rm -rf ./wezterm
fi

git clone --depth=1 --branch=main --recursive https://github.com/wez/wezterm.git
cd wezterm
git submodule update --init --recursive
./get-deps
cargo build --release
#cargo build --release --no-default-features --features=wayland
#cargo build --release --no-default-features --features=x11
#cargo run --release --bin wezterm -- starts

#sudo cp -f target/release/wezterm /usr/local/bin
#sudo cp -f extra/logo/compat/alacritty-term.png /usr/share/pixmaps/Alacritty.png
#sudo desktop-file-install extra/linux/Alacritty.desktop
# /usr/share/applications/Alacritty.desktop
# Exec=env WAYLAND_DISPLAY= alacritty
#sudo sed -i -e s'/^Exec=alacritty/Exec=env WAYLAND_DISPLAY= alacritty/' /usr/share/applications/Alacritty.desktop

#sudo update-desktop-database

cd ~/dotfiles
