#!/usr/bin/env bash

# git config
git config --global user.name 'Yusaku Hieda'
git config --global user.email 'uiyiuyiyi@gmail.com'
git config --global core.editor 'nvim'

git config --global core.pager 'delta'
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate 'true'
git config --global delta.light 'false'

git config --global alias.tree "log --graph --pretty=format:'%x09%C(auto) %h %Cgreen %ar %Creset%x09by\"%C(cyan ul)%an%Creset\" %x09%C(auto)%s %d'"
