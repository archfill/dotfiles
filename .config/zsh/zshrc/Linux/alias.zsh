alias wolmac="wakeonlan 14:98:77:6b:00:00"
alias wol2mac="wol 14:98:77:6b:00:00"
## mount
alias smbmount='(){sudo mount -t cifs -o username=$1,password=$2,domain=$3 $4 $5}'

# Flutter aliases moved to common alias.zsh
# Android Studio aliases moved to common alias.zsh

alias lg='env -u WAYLAND_DISPLAY -u XDG_SESSION_TYPE looking-glass-client -g opengl -C ~/.config/looking-glass/client.conf'
alias lggs='gamescope --backend=sdl -f -W 3440 -H 1440 -r 165 -w 2560 -h 1440 --force-windows-fullscreen --force-grab-cursor --keep-alive -- looking-glass-client -g opengl -C ~/.config/looking-glass/client-gamescope.conf'
