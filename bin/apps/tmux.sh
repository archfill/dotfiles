#!/usr/bin/env bash

function rm-safe() {
  if [ ! -e "$1" ]; then rm -rf $1; fi
}

#tmux
TMUX_PLUGINS_DIR="${HOME}/.tmux/plugins"
if [ ! -e $TMUX_PLUGINS_DIR ]; then
  mkdir -p $TMUX_PLUGINS_DIR
fi

rm-safe "${TMUX_PLUGINS_DIR}/tpm"
git clone https://github.com/tmux-plugins/tpm ${TMUX_PLUGINS_DIR}/tpm

rm-safe "${HOME}/git/tmux-powerline"
git clone https://github.com/chill-rf/tmux-powerline.git ${HOME}/git/tmux-powerline
