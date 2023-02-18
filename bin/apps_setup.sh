#!/usr/bin/env bash

files="${HOME}/dotfiles/bin/apps/*"
for filepath in $files; do
  if [[ ! "${filepath}" == *setup.sh* ]]; then
    bash ${filepath}
  fi
done

