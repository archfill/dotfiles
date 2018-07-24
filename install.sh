#!/bin/sh

# neovim
rm -rf ~/.config/nvim
ln -sf ~/dotfiles/nvim ~/.config/nvim

# vim
rm -rf ~/.vim
ln -sf ~/dotfiles/.vim ~/.vim

rm -f ~/.vimrc
ln -s ~/dotfiles/vimrc ~/.vimrc

rm -f ~/.gvimrc
ln -s ~/dotfiles/gvimrc ~/.gvimrc

#tmux
rm -f ~/.tmux.conf
ln -s ~/dotfiles/.tmux/.tmux.conf ~/.tmux.conf

# zsh
# ln -s ~/dotfiles/zshrc ~/.zshrc

#curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
