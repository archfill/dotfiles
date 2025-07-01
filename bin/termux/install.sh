#!/usr/bin/env bash

pkg install -y zsh \
git \
vim \
neovim \
fzf \
wget \
curl \
git \
clang \
nodejs-lts \
python

# Install bun via npm
if command -v npm >/dev/null 2>&1; then
    echo "Installing bun via npm..."
    npm install -g bun
    echo "bun installed successfully"
else
    echo "npm not available, skipping bun installation"
fi