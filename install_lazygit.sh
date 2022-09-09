export VER="0.35"
mkdir tmp_lazygit
cd tmp_lazygit
wget -O lazygit.tgz https://github.com/jesseduffield/lazygit/releases/download/v${VER}/lazygit_${VER}_Linux_arm64.tar.gz
tar xvf lazygit.tgz
sudo mv lazygit /usr/local/bin/
cd ..
rm -rf tmp_lazygit
