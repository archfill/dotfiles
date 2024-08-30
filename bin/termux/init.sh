#!/usr/bin/env bash

echo "--- setting start ---"

ROOT_DIR="/data/data/com.termux/files/usr"

mkdir -p ${HOME}/.config
mkdir -p ${HOME}/git

mkdir -p ${HOME}/git/termux
mkdir -p ${HOME}/.termux
# color
# ${HOME}/.termux/colors.properties
git clone https://github.com/Iamafnan/termux-tokyonight.git ${HOME}/git/termux/termux-tokyonight
cp ${HOME}/git/termux/termux-tokyonight/colorschemes/tokyonight-night.properties ${HOME}/.termux/colors.properties

# font
# ${HOME}/.termux/font.ttf
HACKGEN_VERSION=v2.9.0
temp_dir=`pwd`
mkdir -p ${HOME}/temp
cd ${HOME}/temp
curl -OL https://github.com/yuru7/HackGen/releases/download/${HACKGEN_VERSION}/HackGen_NF_${HACKGEN_VERSION}.zip
unzip HackGen_NF_${HACKGEN_VERSION}.zip
mv HackGen_NF_${HACKGEN_VERSION}/HackGenConsoleNF-Regular.ttf ${HOME}/.termux/font.ttf
cd $temp_dir
termux-reload-settings

# install
echo "--- apps install setup start ---"
bash ${HOME}/dotfiles/bin/termux/install.sh
echo "--- apps install setup finish ---"

# link
echo "--- link setup start ---"
bash ${HOME}/dotfiles/bin/termux/link.sh
echo "--- link setup finish ---"

# apps
echo "-- apps setup start ---"
bash ${HOME}/dotfiles/bin/apps/zinit.sh
bash ${HOME}/dotfiles/bin/apps/volta.sh
bash ${HOME}/dotfiles/bin/apps/pyenv.sh
echo "-- apps setup finish ---"

chsh -s ${ROOT_DIR}/bin/zsh