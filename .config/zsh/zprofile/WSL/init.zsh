# WSL固有の初期化設定

# WSL環境判定
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
    export WSL_ENV=1
    
    # WSL固有環境変数の読み込み
    [[ -f "${HOME}/.config/wsl/environment" ]] && source "${HOME}/.config/wsl/environment"
    
    # Windows統合エイリアスの読み込み
    [[ -f "${HOME}/.config/wsl/windows_aliases" ]] && source "${HOME}/.config/wsl/windows_aliases"
    
    # WSLバージョン判定
    if grep -qi "wsl2" /proc/version 2>/dev/null; then
        export WSL_VERSION=2
    else
        export WSL_VERSION=1
    fi
    
    # ディストリビューション名の設定
    export WSL_DISTRO="${WSL_DISTRO_NAME:-$(lsb_release -si 2>/dev/null || echo "Unknown")}"
    
    # Windows統合パスの設定
    if [[ -d "/mnt/c/Users" ]]; then
        # 現在のLinuxユーザー名をベースにWindowsユーザーディレクトリを推測
        local win_user="${USER}"
        
        # よくあるWindows ユーザーディレクトリを検索
        for possible_user in "${USER}" "${(L)USER}" "${(C)USER}" "$(whoami)"; do
            if [[ -d "/mnt/c/Users/${possible_user}" ]]; then
                win_user="${possible_user}"
                break
            fi
        done
        
        export WIN_HOME="/mnt/c/Users/${win_user}"
        export WIN_DESKTOP="${WIN_HOME}/Desktop"
        export WIN_DOCUMENTS="${WIN_HOME}/Documents"
        export WIN_DOWNLOADS="${WIN_HOME}/Downloads"
    fi
    
    # WSL固有PATHの追加
    local wsl_paths=(
        "/mnt/c/Windows/System32"
        "/mnt/c/Windows"
        "/mnt/c/Program Files/Git/cmd"
        "/mnt/c/Program Files/Microsoft VS Code/bin"
    )
    
    for wsl_path in "${wsl_paths[@]}"; do
        if [[ -d "$wsl_path" ]] && [[ ":$PATH:" != *":$wsl_path:"* ]]; then
            export PATH="$PATH:$wsl_path"
        fi
    done
    
    # DISPLAYの設定（WSLgサポート）
    if [[ -z "${DISPLAY:-}" ]]; then
        if [[ "$WSL_VERSION" == "2" ]]; then
            # WSL2の場合、自動検出を試行
            export DISPLAY=:0.0
        else
            # WSL1の場合、ホストIPを使用
            export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0"
        fi
    fi
fi