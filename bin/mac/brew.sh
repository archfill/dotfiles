#!/usr/bin/env bash

# sample 配列に対象の文字列が含まれているか
# if printf '%s\n' "${apps_head[@]}" | grep -qx "${v}"; then

apps=(
  'font-fira-code' \
  'font-powerline-symbols' \
  'font-hackgen' \
  'font-hackgen-nerd' \
  'font-hack-nerd-font' \
  'awscli' \
  'bat' \
  'bazelisk' \
  'coreutils' \
  'deno' \
  'direnv' \
  'displayplacer' \
  'dmg2img' \
  'fzf' \
  'ghq' \
  'go' \
  'jenv' \
  'jq' \
  'lazygit' \
  'make' \
  'neomutt' \
  'neovim' \
  'openssl' \
  'openjdk' \
  'openjdk@11' \
  'pyenv' \
  'pyenv-virtualenv' \
  'qmk' \
  'readline' \
  'ranger' \
  'ripgrep' \
  'sqlite3' \
  'skhd' \
  'stripe' \
  'tmux' \
  'the_silver_searcher' \
  'tcl-tk' \
  'w3m' \
  'wakeonlan' \
  'wget' \
  'xz' \
  'yabai' \
  'yq' \
  'zlib' \
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
brew tap gcenx/wine
brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew tap homebrew/core
brew tap homebrew/services
brew tap jakehilborn/jakehilborn
brew tap koekeishiya/formulae
brew tap osx-cross/arm
brew tap osx-cross/avr
brew tap qmk/qmk
brew tap stripe/stripe-cli

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

