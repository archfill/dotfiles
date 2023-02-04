#!/usr/bin/env bash

# pyenv
git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv

# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.temp_profile
# echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${HOME}/.temp_profile
# source ${HOME}/.temp_profile
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pyenv-virtualenv
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
