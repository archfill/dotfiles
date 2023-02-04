#!/usr/bin/env bash

# git config
git config --global user.name 'Yusaku Hieda'
git config --global user.email 'y.hieda@chill-rf.com'
git config --global core.editor 'nvim'

git config --global core.pager 'delta'
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate 'true'
git config --global delta.light 'false'
