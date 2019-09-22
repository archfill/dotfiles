#!/bin/sh

echo "setup start"

FONT_CICA='v5.0.1'

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
rm -rf ~/.config/nvim
ln -sf ~/dotfiles/nvim ~/.config/nvim

# alacritty
echo "alactritty"
rm -rf ~/.config/alacritty
ln -sf ~/dotfiles/.config/alacritty ~/.config/alacritty

# neomutt
rm -f ~/.muttrc
ln -s ~/dotfiles/.muttrc ~/.muttrc
rm -rf ~/.mutt
ln -sf ~/dotfiles/.mutt ~/.mutt

# vim
#rm -rf ~/.vim
#ln -sf ~/dotfiles/.vim ~/.vim

rm -f ~/.vimrc
ln -s ~/dotfiles/.vimrc ~/.vimrc

rm -f ~/.gvimrc
ln -s ~/dotfiles/.gvimrc ~/.gvimrc

#tmux
TMUX_DIR=~/.tmux
TMUX_PLUGINS_DIR=${TMUX_DIR}/plugins
if [ ! -e $TMUX_PLUGINS_DIR ]; then
  mkdir -p $TMUX_PLUGINS_DIR
fi
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

: "install zplug" && {
  ZPLUG_DIR=$HOME/.zplug
  if [ ! -e $ZPLUG_DIR ]; then
    info "installing zplug..."
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  else
    warn "zplug is already installed"
  fi
}

# opam
: "install opam" && {
  OPAM_DIR=$HOME/.opam
  if [ ! -e $OPAM_DIR ]; then
    info "installing opam..."
    mkdir opam-work && cd opam-work
    curl -OL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh
    chmod +x ./install.sh
    sh ./install.sh
    opam init
  else
    warn "opam is already installed"
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
FONT_CICA_TERGET=Cica_${FONT_CICA}_with_emoji.zip
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

exit 0
