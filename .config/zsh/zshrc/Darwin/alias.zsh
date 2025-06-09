alias mvim=/Applications/MacVim.app/Contents/bin/mvim "$@"
alias bau='brew update && brew upgrade --greedy'
alias bwupgrade='brew update && brew upgrade'
alias intelzsh='arch -x86_64 zsh'
alias yabai-restart='yabai --restart-service'

# Flutter development aliases (macOS)
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

# iOS Simulator shortcuts (macOS only)
alias ios='open -a Simulator'
alias iphone='xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "iPhone 15 Pro simulator not available"'

# Android Studio and Android development
alias studio='open -a "Android Studio"'
