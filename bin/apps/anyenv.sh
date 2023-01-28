#!/usr/bin/env bash

function rm-safe() {
  if [ ! -e "$1" ]; then rm -rf $1; fi
}

# anyenv
rm-safe "~/.anyenv"
git clone https://github.com/anyenv/anyenv ~/.anyenv

# echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ${HOME}/.temp_profile
# echo 'export ANYENV_ROOT="$HOME/.anyenv"' >> ${HOME}/.temp_profile
# source ${HOME}/.temp_profile
export PATH="$HOME/.anyenv/bin:$PATH"
export ANYENV_ROOT="$HOME/.anyenv"
$HOME/.anyenv/bin/anyenv init
anyenv install --force-init
