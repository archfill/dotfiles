alias wolmac="wakeonlan 14:98:77:6b:00:00"
alias wol2mac="wol 14:98:77:6b:00:00"
## feh
alias sbg-home="sh ~/bin/wallpaper-home.sh"
alias sbg-work="sh ~/bin/wallpaper-work.sh"
## mount
alias smbmount='(){sudo mount -t cifs -o username=$1,password=$2,domain=$3 $4 $5}'

# Flutter aliases moved to common alias.zsh
# Android Studio aliases moved to common alias.zsh

# claude-mem orphan process cleanup (Issue #499 workaround)
alias claude-mem-cleanup='pkill -f "claude.*disallowedTools" && echo "Orphaned claude-mem processes killed"'
alias claude-mem-status='ps aux | grep -E "claude.*disallowedTools|mcp-server.cjs|worker-service" | grep -v grep'
