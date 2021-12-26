#!/bin/bash

cd ~/git/
git clone https://github.com/wachikun/yaskkserv2.git

# 辞書
git clone https://github.com/skk-dev/dict.git
git clone https://github.com/tokuhirom/skk-jisyo-neologd.git

cd yaskkserv2
cargo build --release

cp -av target/release/yaskkserv2 /usr/local/bin/
cp -av target/release/yaskkserv2_make_dictionary /usr/local/bin/

yaskkserv2_make_dictionary --dictionary-filename=$HOME/.config/skk/dictionary.yaskkserv2 $HOME/git/dict/SKK-JISYO.L

