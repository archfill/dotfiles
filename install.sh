#!/usr/bin/env bash

echo "dotfiles setup start."

if [ "$(uname)" = 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
  OS='Linux'
elif [ "$(expr substr $(uname -s) 1 10)" = 'MINGW32_NT' ]; then
  OS='Cygwin'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

mkdir -p ~/.config

# link
echo "link setup start."
bash ${HOME}/dotfiles/bin/link.sh
echo "link setup finish."

echo "check os..."
if [ "$OS" = 'Mac' ]; then
  bash ./install_mac.sh
elif [ "$OS" = 'Linux' ]; then
  # fonts setup
  bash ${HOME}/dotfiles/bin/linux/fonts_setup.sh
  bash ${HOME}/dotfiles/bin/linux/deno_install.sh
  bash ./install_linux.sh
elif [ "$OS" = 'Cygwin' ]; then
  bash ./install_cygwin.sh
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

# apps setup
echo "apps setup start."
bash ${HOME}/dotfiles/bin/apps/setup.sh
echo "apps setup finish."

# git config
git config --global user.name 'Yusaku Hieda'
git config --global user.email 'y.hieda@chill-rf.com'
git config --global core.editor 'nvim'

git config --global core.pager 'delta'
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate 'true'
git config --global delta.light 'false'

exit 0
