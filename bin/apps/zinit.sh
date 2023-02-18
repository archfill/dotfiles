# zsh
ZINIT_DIR=$HOME/.zinit
if [ ! -e $ZINIT_DIR ]; then
  mkdir $ZINIT_DIR
  git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_DIR/bin
else
  echo "zinit skip."
fi
