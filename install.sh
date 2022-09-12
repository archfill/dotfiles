#!/bin/sh

echo "setup start"

FONT_CICA='v5.0.3'
FONT_HACKGEN='v2.7.1'

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

# neomutt
MUTTRC_FILE=~/.muttrc
unlink $MUTTRC_FILE
rm -f $MUTTRC_FILE
ln -s ~/dotfiles/.muttrc $MUTTRC_FILE
MUTT_DIR=~/.mutt
unlink $MUTT_DIR
rm -rf $MUTT_DIR
ln -sf ~/dotfiles/.mutt $MUTT_DIR

# vim
#rm -rf ~/.vim
#ln -sf ~/dotfiles/.vim ~/.vim

# ideavim
ln -s ~/dotfiles/.ideavimrc ~/.ideavimrc

VIMRC_FILE=~/.vimrc
unlink $VIMRC_FILE
rm -f $VIMRC_FILE
ln -s ~/dotfiles/.vimrc $VIMRC_FILE

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
ln -sf ~/dotfiles/.tmux/plugins/tpm/ ${TMUX_PLUGINS_DIR}/tpm
rm -rf ~/git/tmux-powerline
ln -sf ~/dotfiles/.tmux/git/tmux-powerline/ ~/git/tmux-powerline

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
ln -sf ~/dotfiles/.anyenv ~/.anyenv

git submodule init
git submodule update
# git submodule update --init --recursive
# git submodule foreach git pull origin master

~/.anyenv/bin/anyenv init
anyenv install --init

# sed -i -e 's/export ZSH=.*/export ZSH="~\/.oh-my-zsh"/g' test.txt
# sed -i -e 's/ZSH_THEME=.*/ZSH_THEME="powerlevel9k\/powerlevel9k"/' test.txt
# echo 'alias vi="nvim"' >> test.txt
# echo 'alias vim="nvim"' >> test.txt

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

rm -rf ~/.git_tmp
ln -sf ~/dotfiles/.git_tmp ~/.git_tmp

cd
git config --global init.templatedir '.git_tmp' 
git config --global user.name 'Yusaku Hieda' 
git config --global user.name 'y.hieda@chill-rf.com' 

exit 0
