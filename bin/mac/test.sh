#!/usr/bin/env bash

apps=(
  'font-fira-code' \
  'font-powerline-symbols' \
  'font-hackgen' \
  'font-hackgen-nerd' \
  'font-hack-nerd-font' \
  'deno' \
  'ghq' \
  'go' \
  'coreutils' \
  'direnv' \
  '--HEAD neovim' \
  '--cask altserver' \
  '--cask android-platform-tools' \
  '--cask appflowy' \
  '--cask aquaskk' \
  '--cask biscuit' \
  '--cask yt-music' \
  '--cask utm' \
  '--cask via' \
  '--cask warp' \
  '--cask wezterm' \
  '--cask xcodes' \
  '--cask hammerspoon' \
  '--cask kitty' \
  '--cask lapce' \
  '--cask nextcloud' \
  '--cask gitup' \
  '--cask google-cloud-sdk' \
  '--cask cscreen' \
  '--cask devtoys' \
  '--cask finch' \
  '--cask blackhole-16ch' \
  '--cask blackhole-2ch' \
  '--cask blackhole-64ch' \
  '--cask brewlet' \
  '--cask cheatsheet' \
  '--cask --no-quarantine gcenx/wine/unofficial-wineskin'
)

# brew tap
brew tap homebrew/cask-fonts

for v in "${apps[@]}"
do
  if [[ "${v}" == *--HEAD* ]]; then
    # build install
    app_name=`echo ${v} | sed -e "s/--HEAD//"`
  elif [[ "${v}" == *gcenx/wine/unofficial-wineskin* ]]; then
    # cask install
    app_name=`echo ${v} | sed -e "s/--cask --no-quarantine gcenx\/wine\///"`
  elif [[ "${v}" == *--cask* ]]; then
    # cask install
    app_name=`echo ${v} | sed -e "s/--cask//"`
  else
    # latest install
    app_name="${v}"
  fi

  echo "brew unlink ${app_name}"
  echo "brew uninstall ${app_name}"
  echo "brew install ${v}"
done
