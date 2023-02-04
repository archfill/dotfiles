#!/usr/bin/env bash

echo "dotfiles setup start."

mkdir -p ~/.config

# link
echo "link setup start."
bash ${HOME}/dotfiles/bin/link.sh
echo "link setup finish."

echo "check os..."
if [ "$(uname)" = 'Darwin' ]; then
  # mac
  echo "this is os mac."
  bash ${HOME}/dotfiles/bin/mac/link.sh
  bash ${HOME}/dotfiles/bin/mac/brew.sh
  bash ${HOME}/dotfiles/bin/mac/config.sh
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
  # linux
  echo "this is os linux."
  ## fonts setup
  bash ${HOME}/dotfiles/bin/linux/apps/fonts_setup.sh
  bash ${HOME}/dotfiles/bin/linux/apps/deno_install.sh
  bash ${HOME}/dotfiles/bin/linux/apps/neovim_install.sh

  bash ${HOME}/dotfiles/bin/linux/install_linux.sh
elif [ "$(expr substr $(uname -s) 1 10)" = 'MINGW32_NT' ]; then
  # cygwin
  echo "this is os windows."
  bash ${HOME}/dotfiles/bin/cygwin/install_cygwin.sh
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

# apps setup
echo "apps setup start."
bash ${HOME}/dotfiles/bin/apps_setup.sh
echo "apps setup finish."

# config setup
echo "config setup start."
bash ${HOME}/dotfiles/bin/config.sh
echo "config setup finish."

echo "dotfiles setup finish."
exit 0
