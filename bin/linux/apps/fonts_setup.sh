#!/usr/bin/env bash

# udev gothic
# mkdir -p ~/.local/share/fonts/UDEVGothic
# UDEV_GOTHIC_RELEASES_URL="https://api.github.com/repos/yuru7/udev-gothic/releases"
# curl -sfL "${UDEV_GOTHIC_RELEASES_URL}" | jq -r '.[0].assets | .[].browser_download_url' | grep _NF_ | xargs -I{} curl -fL -o /tmp/UDEVGothic.zip "{}"
# (cd /tmp && unzip -j -o UDEVGothic.zip -d ~/.local/share/fonts/UDEVGothic)

# cica
# mkdir -p ~/.local/share/fonts/cica
# CICA_RELEASES_URL="https://api.github.com/repos/miiton/Cica/releases"
# curl -sfL "${CICA_RELEASES_URL}" | jq -r '.[0].assets | .[].browser_download_url' | grep -i without_emoji.zip | xargs -I{} curl -fL -o /tmp/Cica.zip "{}"
# (cd /tmp && unzip -o Cica.zip -d ~/.local/share/fonts/cica)

function mkdir-safe() {
  if [ ! -e $1 ]; then mkdir -p $1; fi
}

FONT_CICA='v5.0.3'
FONT_HACKGEN='v2.8.0'

FONTS_DIR="${HOME}/.fonts"
mkdir-safe "${FONTS_DIR}"

HOME_TEMP_DIR="${HOME}/temp"
mkdir-safe "${HOME_TEMP_DIR}"
cd ${HOME_TEMP_DIR}

FONT_TEMP_DIR="./font_tmp"
mkdir-safe "${FONT_TEMP_DIR}"

# font cica
FONT_CICA_TERGET=Cica_${FONT_CICA}.zip
cd ${FONT_TEMP_DIR}
curl -OL https://github.com/miiton/Cica/releases/download/${FONT_CICA}/${FONT_CICA_TERGET}
unzip $FONT_CICA_TERGET
mv ./Cica*.ttf ${FONTS_DIR}
cd ../
rm -rf ${FONT_TEMP_DIR}

# font hackgen
FONT_HACKGEN_FOLDER_NAME=HackGen_NF_${FONT_HACKGEN}
FONT_HACKGEN_TERGET=${FONT_HACKGEN_FOLDER_NAME}.zip
cd ${FONT_TEMP_DIR}
curl -OL https://github.com/yuru7/HackGen/releases/download/${FONT_HACKGEN}/${FONT_HACKGEN_TERGET}
unzip $FONT_HACKGEN_TERGET
mv ./$FONT_HACKGEN_FOLDER_NAME/HackGen*.ttf ${FONTS_DIR}
cd ../
rm -rf $FONT_TEMP_DIR

fc-cache -fv

cd ${HOME}/dotfiles
