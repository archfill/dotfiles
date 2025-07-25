#!/usr/bin/env bash

function link() {
  TARGET_PATH="${HOME}/$1"
  DOT_PATH="${HOME}/dotfiles/$1"

  if [ -d $TARGET_PATH ]; then
    rm -rf $TARGET_PATH
  fi
  ln -snf $DOT_PATH $TARGET_PATH
}

# neovim
link ".config/nvim"
# vim
link ".vimrc"
# # vim gui
# link ".gvimrc"
# # ideavim
# link ".ideavimrc"
# # alacritty
# link ".config/alacritty"
# # kitty
# link ".config/kitty"
# # wezterm
# link ".config/wezterm"
# # direnv
# link ".config/direnv"
# # neomutt
# link ".muttrc"
# link ".mutt"
# link ".textlintrc"

#tmux
TMUX_DIR="${HOME}/.tmux"
if [ ! -d $TMUX_DIR ]; then
  mkdir -p $TMUX_DIR
fi
link ".tmux/bin"
# Special mapping: .config/tmux/tmux.conf → ~/.tmux.conf
if [ -f "${HOME}/dotfiles/.config/tmux/tmux.conf" ]; then
  ln -snf "${HOME}/dotfiles/.config/tmux/tmux.conf" "${HOME}/.tmux.conf"
fi
# link ".tmux-powerlinerc"  # Removed: not using tmux-powerline anymore

# zsh
if [ -f "${HOME}/.zshrc" ]; then rm -f ${HOME}/.zshrc; fi
if [ -e "${HOME}/.zsh" ]; then rm -rf ${HOME}/.zsh; fi
link ".config/zsh"
link ".zshenv"

# sheldon & starship (modern zsh setup)
link ".config/sheldon"
link ".config/starship.toml"

