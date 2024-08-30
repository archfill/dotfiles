#!/usr/bin/env bash

echo "--- setting start ---"

mkdir -p ${HOME}/.config

# install
echo "--- apps install setup start ---"
bash ${HOME}/dotfiles/bin/termux/install.sh
echo "--- apps install setup finish ---"

# link
echo "--- link setup start ---"
bash ${HOME}/dotfiles/bin/termux/link.sh
echo "--- link setup finish ---"

# apps
echo "-- apps setup start ---"
bash ${HOME}/dotfiles/bin/apps/zinit.sh
bash ${HOME}/dotfiles/bin/apps/volta.sh
bash ${HOME}/dotfiles/bin/apps/pyenv.sh
echo "-- apps setup finish ---"