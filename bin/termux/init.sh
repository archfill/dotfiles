#!/usr/bin/env bash

echo "--- setting start ---"

mkdir -p ${HOME}/.config

# link
echo "link setup start."
bash ${HOME}/dotfiles/bin/termux/link.sh
echo "link setup finish."