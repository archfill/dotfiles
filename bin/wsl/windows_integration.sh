#!/usr/bin/env bash

# Windows統合機能専用スクリプト
# WSLとWindowsの統合機能を設定

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Setting up Windows integration features"

# Windows Terminal設定の最適化
setup_windows_terminal() {
    log_info "Setting up Windows Terminal integration..."
    
    local wt_settings_dir="/mnt/c/Users/$(whoami)/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
    local wt_settings_file="$wt_settings_dir/settings.json"
    
    if [[ -d "$wt_settings_dir" && -f "$wt_settings_file" ]]; then
        log_info "Windows Terminal settings found, creating backup"
        cp "$wt_settings_file" "$wt_settings_file.backup.$(date +%Y%m%d_%H%M%S)"
        log_success "Windows Terminal settings backed up"
    else
        log_warning "Windows Terminal not found or settings not accessible"
    fi
}

# Windowsアプリケーション統合エイリアス
setup_windows_app_aliases() {
    log_info "Setting up Windows application aliases..."
    
    local alias_file="${HOME}/.config/wsl/windows_aliases"
    mkdir -p "$(dirname "$alias_file")"
    
    cat > "$alias_file" << 'EOF'
# Windows アプリケーション統合エイリアス

# ファイル管理
alias explorer='explorer.exe'
alias open='explorer.exe'

# テキストエディタ
alias notepad='notepad.exe'
alias code='/mnt/c/Users/$(whoami)/AppData/Local/Programs/Microsoft\ VS\ Code/bin/code'

# ブラウザ
alias chrome='/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe'
alias edge='/mnt/c/Program\ Files\ \(x86\)/Microsoft/Edge/Application/msedge.exe'

# システム
alias cmd='cmd.exe'
alias powershell='powershell.exe'
alias pwsh='pwsh.exe'

# クリップボード
alias pbcopy='win32yank -i'
alias pbpaste='win32yank -o'

# Windows ユーティリティ
alias calc='calc.exe'
alias mspaint='mspaint.exe'

# ネットワーク
alias ipconfig='ipconfig.exe'
alias ping='ping.exe'

# ファイル操作
wopen() {
    if [[ $# -eq 0 ]]; then
        explorer.exe .
    else
        explorer.exe "$(wslpath -w "$1")"
    fi
}

# Windows パスに変換
wpath() {
    wslpath -w "$1"
}

# Linux パスに変換
lpath() {
    wslpath -u "$1"
}
EOF
    
    log_success "Windows application aliases created"
}

# フォント設定
setup_wsl_fonts() {
    log_info "Setting up WSL font configuration..."
    
    # Windows フォントへのシンボリックリンク作成
    local windows_fonts="/mnt/c/Windows/Fonts"
    local local_fonts="${HOME}/.local/share/fonts"
    
    if [[ -d "$windows_fonts" ]]; then
        mkdir -p "$local_fonts"
        
        # 日本語フォントのリンク作成
        for font in "meiryo.ttc" "msgothic.ttc" "msmincho.ttc" "YuGothic.ttf" "YuMincho.ttf"; do
            if [[ -f "$windows_fonts/$font" && ! -L "$local_fonts/$font" ]]; then
                ln -sf "$windows_fonts/$font" "$local_fonts/$font"
                log_info "Linked font: $font"
            fi
        done
        
        # フォントキャッシュ更新
        fc-cache -fv 2>/dev/null || true
        log_success "Font configuration completed"
    else
        log_warning "Windows fonts directory not accessible"
    fi
}

# Git設定の最適化（WSL環境向け）
setup_wsl_git_config() {
    log_info "Setting up WSL-specific Git configuration..."
    
    # WSL環境でのGit設定最適化
    git config --global core.autocrlf input
    git config --global core.filemode false
    git config --global core.fscache true
    
    # WSL2でのGit credential helper設定
    if is_wsl2; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe"
    fi
    
    log_success "WSL Git configuration completed"
}

# メイン実行
main() {
    if ! is_wsl; then
        log_error "This script is designed for WSL environments only"
        exit 1
    fi
    
    setup_windows_terminal
    setup_windows_app_aliases
    setup_wsl_fonts
    setup_wsl_git_config
    
    log_success "Windows integration setup completed"
    log_info "Some changes may require restarting your WSL session"
}

# スクリプトが直接実行された場合のみmainを呼び出し
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi