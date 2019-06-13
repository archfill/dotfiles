#!/bin/sh

echo "setup start"

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

# vim
rm -rf ~/.vim
ln -sf ~/dotfiles/.vim ~/.vim

rm -f ~/.vimrc
ln -s ~/dotfiles/.vimrc ~/.vimrc

rm -f ~/.gvimrc
ln -s ~/dotfiles/.gvimrc ~/.gvimrc

#tmux
rm -rf ~/.tmux
ln -sf ~/dotfiles/.tmux/ ~/.tmux

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

echo "check os..."
if [ "$OS" = 'Mac' ]; then
  sh ./install_mac.sh
elif [ "$OS" = 'Linux' ]; then
  sh ./install_linux.sh
elif [ "$OS" = 'Cygwin' ]; then
  sh ./install_cygwin.sh
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

exit 0
