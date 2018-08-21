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

#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# zsh
# ln -s ~/dotfiles/zshrc ~/.zshrc
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
