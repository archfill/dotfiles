alias wolmac="wakeonlan 14:98:77:6b:00:00"
alias wol2mac="wol 14:98:77:6b:00:00"
## feh
alias sbg-home="sh ~/bin/wallpaper-home.sh"
alias sbg-work="sh ~/bin/wallpaper-work.sh"
## google-drive-ocamlfuse 
alias gdmount='google-drive-ocamlfuse ~/gdchillda'
## mount
alias smbmount='(){sudo mount -t cifs -o username=$1,password=$2,domain=$3 $4 $5}'

# Flutter development aliases (Linux)
alias fl='flutter'
alias flpub='flutter pub'
alias flrun='flutter run'
alias flclean='flutter clean'
alias fldoc='flutter doctor'
alias fltest='flutter test'

# FVM aliases (if FVM is available)
if command -v fvm >/dev/null 2>&1; then
  alias fvmlist='fvm list'
  alias fvmuse='fvm use'
  alias fvminstall='fvm install'
fi

# Linux Android development
if command -v android-studio >/dev/null 2>&1; then
  alias studio='android-studio'
elif [ -f "/opt/android-studio/bin/studio.sh" ]; then
  alias studio='/opt/android-studio/bin/studio.sh'
fi
