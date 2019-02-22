#!/bin/sh

if [ "$(uname)" = 'Darwin' ]; then
  OS='Mac'
  echo $OS
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
  OS='Linux'
  echo $OS
elif [ "$(expr substr $(uname -s) 1 10)" = 'MINGW32_NT' ]; then
  OS='Cygwin'
  echo $OS
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

# neovim
rm -rf ~/.config/nvim
ln -sf ~/dotfiles/nvim ~/.config/nvim

# alacritty
rm -rf ~/.config/alacritty
ln -sf ~/dotfiles/.config/alacritty ~/.config/alacritty

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
cd ~/dotfiles
rm -f ~/.zshrc
ln -s ~/dotfiles/.zshrc ~/.zshrc

# sed -i -e 's/export ZSH=.*/export ZSH="~\/.oh-my-zsh"/g' test.txt
# sed -i -e 's/ZSH_THEME=.*/ZSH_THEME="powerlevel9k\/powerlevel9k"/' test.txt
# echo 'alias vi="nvim"' >> test.txt
# echo 'alias vim="nvim"' >> test.txt
