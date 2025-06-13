# WSL固有エイリアス

# WSL環境でのみ有効
if [[ -n "${WSL_ENV:-}" ]]; then
    
    # Windows アプリケーション統合
    alias explorer='explorer.exe'
    alias open='explorer.exe'
    alias notepad='notepad.exe'
    alias calc='calc.exe'
    alias mspaint='mspaint.exe'
    
    # システムコマンド
    alias cmd='cmd.exe'
    alias powershell='powershell.exe'
    alias pwsh='pwsh.exe'
    
    # ネットワークコマンド
    alias ipconfig='ipconfig.exe'
    alias ping='ping.exe'
    alias nslookup='nslookup.exe'
    
    # クリップボード操作（win32yankが利用可能な場合）
    if command -v win32yank >/dev/null 2>&1; then
        alias pbcopy='win32yank -i'
        alias pbpaste='win32yank -o'
        alias clip='win32yank -i'
    elif command -v clip.exe >/dev/null 2>&1; then
        alias clip='clip.exe'
    fi
    
    # VS Code統合
    if [[ -x "/mnt/c/Program Files/Microsoft VS Code/bin/code" ]]; then
        alias code='"/mnt/c/Program Files/Microsoft VS Code/bin/code"'
    elif command -v code.exe >/dev/null 2>&1; then
        alias code='code.exe'
    fi
    
    # ブラウザ起動
    if [[ -x "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" ]]; then
        alias chrome='"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"'
    fi
    
    if [[ -x "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" ]]; then
        alias edge='"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"'
    fi
    
    # Windowsターミナル
    if command -v wt.exe >/dev/null 2>&1; then
        alias wt='wt.exe'
    fi
    
    # WSL固有のユーティリティ関数
    
    # Windowsエクスプローラーでカレントディレクトリを開く
    wopen() {
        if [[ $# -eq 0 ]]; then
            explorer.exe .
        else
            local target="$1"
            if [[ -d "$target" ]]; then
                explorer.exe "$(wslpath -w "$target")"
            elif [[ -f "$target" ]]; then
                explorer.exe /select,"$(wslpath -w "$target")"
            else
                echo "Error: '$target' not found" >&2
                return 1
            fi
        fi
    }
    
    # パス変換ユーティリティ
    wpath() {
        if [[ $# -eq 0 ]]; then
            wslpath -w "$(pwd)"
        else
            wslpath -w "$1"
        fi
    }
    
    lpath() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: lpath <windows_path>"
            return 1
        else
            wslpath -u "$1"
        fi
    }
    
    # Windows側のホームディレクトリに移動
    cdhome() {
        if [[ -n "${WIN_HOME:-}" ]] && [[ -d "$WIN_HOME" ]]; then
            cd "$WIN_HOME"
        else
            echo "Windows home directory not found"
            return 1
        fi
    }
    
    # Windows側のデスクトップに移動
    cddesktop() {
        if [[ -n "${WIN_DESKTOP:-}" ]] && [[ -d "$WIN_DESKTOP" ]]; then
            cd "$WIN_DESKTOP"
        else
            echo "Windows desktop directory not found"
            return 1
        fi
    }
    
    # Windows側のダウンロードフォルダに移動
    cddownloads() {
        if [[ -n "${WIN_DOWNLOADS:-}" ]] && [[ -d "$WIN_DOWNLOADS" ]]; then
            cd "$WIN_DOWNLOADS"
        else
            echo "Windows downloads directory not found"
            return 1
        fi
    }
    
    # WSL情報表示
    wslinfo() {
        echo "WSL Environment Information:"
        echo "  Version: ${WSL_VERSION:-Unknown}"
        echo "  Distribution: ${WSL_DISTRO:-Unknown}"
        echo "  Distro Name: ${WSL_DISTRO_NAME:-Not set}"
        echo "  Windows Home: ${WIN_HOME:-Not found}"
        echo "  Display: ${DISPLAY:-Not set}"
        echo ""
        echo "Available Windows integration:"
        command -v explorer.exe >/dev/null && echo "  ✓ Explorer"
        command -v code.exe >/dev/null && echo "  ✓ VS Code"
        command -v win32yank >/dev/null && echo "  ✓ Clipboard (win32yank)"
        command -v clip.exe >/dev/null && echo "  ✓ Clipboard (clip.exe)"
        command -v wt.exe >/dev/null && echo "  ✓ Windows Terminal"
    }
    
fi