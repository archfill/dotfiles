#!/bin/bash

echo "setup start"

FONT_CICA='v5.0.3'
FONT_HACKGEN='v2.7.1'

VAR_NVM='v0.39.1'

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
# neovim
echo "neovim"
NEOVIM_DIR=~/.config/nvim
unlink $NEOVIM_DIR
rm -rf $NEOVIM_DIR
ln -sf ~/dotfiles/nvim $NEOVIM_DIR

# alacritty
echo "alactritty"
ALACTRITTY_DIR=~/.config/alacritty
unlink $ALACTRITTY_DIR
rm -rf $ALACTRITTY_DIR
ln -sf ~/dotfiles/.config/alacritty $ALACTRITTY_DIR

# kitty
echo "kitty"
KITTY_DIR=~/.config/kitty
unlink $KITTY_DIR
rm -rf $KITTY_DIR
ln -sf ~/dotfiles/.config/kitty $KITTY_DIR

# wezterm
echo "wezterm"
WEZTERM_DIR=~/.config/wezterm
unlink $WEZTERM_DIR
rm -rf $WEZTERM_DIR
ln -sf ~/dotfiles/.config/wezterm $WEZTERM_DIR

# direnv
echo "direnv"
DIRENV_DIR=~/.config/direnv
unlink $DIRENV_DIR
rm -rf $DIRENV_DIR
ln -sf ~/dotfiles/.config/direnv $DIRENV_DIR

# neomutt
MUTTRC_FILE=~/.muttrc
unlink $MUTTRC_FILE
rm -f $MUTTRC_FILE
ln -s ~/dotfiles/.muttrc $MUTTRC_FILE
MUTT_DIR=~/.mutt
unlink $MUTT_DIR
rm -rf $MUTT_DIR
ln -sf ~/dotfiles/.mutt $MUTT_DIR

# ideavim
ln -s ~/dotfiles/.ideavimrc ~/.ideavimrc
# vim
VIMRC_FILE=~/.vimrc
unlink $VIMRC_FILE
rm -f $VIMRC_FILE
ln -s ~/dotfiles/.vimrc $VIMRC_FILE

# vim gui
GVIMRC_FILE=~/.gvimrc
unlink $GVIMRC_FILE
rm -f $GVIMRC_FILE
ln -s ~/dotfiles/.gvimrc $GVIMRC_FILE

#tmux
TMUX_DIR=~/.tmux
TMUX_PLUGINS_DIR=${TMUX_DIR}/plugins
unlink ${TMUX_DIR}

if [ ! -e $TMUX_PLUGINS_DIR ]; then
  mkdir -p $TMUX_PLUGINS_DIR
fi

unlink ${TMUX_DIR}/bin
rm -rf ${TMUX_DIR}/bin
ln -sf ~/dotfiles/.tmux/bin/ ${TMUX_DIR}/bin

rm -rf ${TMUX_PLUGINS_DIR}/tpm
git clone https://github.com/tmux-plugins/tpm ${TMUX_PLUGINS_DIR}/tpm

rm -rf ~/git/tmux-powerline
git clone https://github.com/chill-rf/tmux-powerline.git ${HOME}/git/tmux-powerline

rm -f ~/.tmux.conf
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
rm -f ~/.tmux-powerlinerc
ln -s ~/dotfiles/.tmux-powerlinerc ~/.tmux-powerlinerc

# zsh
rm -f ~/.zshrc
rm -rf ~/.zsh
ln -sf ~/dotfiles/.zsh ~/.zsh
rm -f ~/.zshenv
ln -s ~/dotfiles/.zshenv ~/.zshenv

: "install zinit" && {
  ZINIT_DIR=$HOME/.zinit
  if [ ! -e $ZINIT_DIR ]; then
    echo "installing zinit..."
    mkdir $ZINIT_DIR
    git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_DIR/bin
  else
    echo "zinit is already installed"
  fi
}

# anyenv
rm -rf ~/.anyenv

git clone https://github.com/anyenv/anyenv ~/.anyenv

echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ${HOME}/.bash_profile
echo 'export ANYENV_ROOT="$HOME/.anyenv"' >> ${HOME}/.bash_profile
source ${HOME}/.bash_profile
$HOME/.anyenv/bin/anyenv init
anyenv install --force-init

echo "check os..."
if [ "$OS" = 'Mac' ]; then
  bash ./install_mac.sh
elif [ "$OS" = 'Linux' ]; then
  bash ./install_linux.sh
elif [ "$OS" = 'Cygwin' ]; then
  bash ./install_cygwin.sh
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

# font cica
sudo pacman -Suy unzip
FONT_CICA_TERGET=Cica_${FONT_CICA}.zip
FONT_CICA_TEMP_DIR=./font_tmp
if [ ! -e $FONT_CICA_TEMP_DIR ]; then
  mkdir $FONT_CICA_TEMP_DIR
fi
cd $FONT_CICA_TEMP_DIR
curl -OL https://github.com/miiton/Cica/releases/download/${FONT_CICA}/${FONT_CICA_TERGET}
unzip $FONT_CICA_TERGET

FONTS_DIR=~/.fonts
if [ ! -e $FONTS_DIR ]; then
  mkdir $FONTS_DIR
fi
mv ./Cica*.ttf ~/.fonts/
fc-cache -fv
cd ~/dotfiles
rm -rf $FONT_CICA_TEMP_DIR

# font hackgen
FONT_HACKGEN_FOLDER_NAME=HackGen_NF_${FONT_HACKGEN}
FONT_HACKGEN_TERGET=${FONT_HACKGEN_FOLDER_NAME}.zip
FONT_HACKGEN_TEMP_DIR=./font_tmp
if [ ! -e $FONT_HACKGEN_TEMP_DIR ]; then
  mkdir $FONT_HACKGEN_TEMP_DIR
fi
cd $FONT_HACKGEN_TEMP_DIR
curl -OL https://github.com/yuru7/HackGen/releases/download/${FONT_HACKGEN}/${FONT_HACKGEN_TERGET}
unzip $FONT_HACKGEN_TERGET

FONTS_DIR=~/.fonts
if [ ! -e $FONTS_DIR ]; then
  mkdir $FONTS_DIR
fi
mv ./$FONT_HACKGEN_FOLDER_NAME/HackGen*.ttf ~/.fonts/
fc-cache -fv
cd ~/dotfiles
rm -rf $FONT_HACKGEN_TEMP_DIR

# deno
curl -fsSL https://deno.land/install.sh | sh

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${VAR_NVM}/install.sh | bash

# pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

# pyenv-virtualenv
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

# git config
git config --global user.name 'Yusaku Hieda' 
git config --global user.email 'y.hieda@chill-rf.com' 

exit 0
