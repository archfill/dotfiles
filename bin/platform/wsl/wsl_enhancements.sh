#!/usr/bin/env bash

# WSL固有機能追加スクリプト
# 既存のLinux設定に追加でWSL固有機能を設定

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/common.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting WSL enhancements setup"

# WSL環境チェック
if ! is_wsl; then
    log_error "This script is designed for WSL environments only"
    exit 1
fi

# WSLバージョン情報
if is_wsl1; then
    log_info "Detected WSL1 environment"
elif is_wsl2; then
    log_info "Detected WSL2 environment"
else
    log_info "Detected WSL environment (version unknown)"
fi

log_info "WSL Distribution: $(get_wsl_distro_name)"

# Windows統合機能の設定
setup_windows_integration() {
    log_info "Setting up Windows integration..."
    
    # win32yankのインストール (クリップボード統合)
    if ! command -v win32yank >/dev/null 2>&1; then
        if command -v pacman >/dev/null 2>&1; then
            # Arch Linux
            yay -S --noconfirm win32yank
        elif command -v apt >/dev/null 2>&1; then
            # Ubuntu/Debian
            curl -Lo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
            unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
            chmod +x /tmp/win32yank.exe
            sudo mv /tmp/win32yank.exe /usr/local/bin/win32yank
            rm -f /tmp/win32yank.zip
        fi
    fi
    
    log_success "Windows integration setup completed"
}

# WSLパフォーマンス最適化
setup_wsl_optimization() {
    log_info "Setting up WSL performance optimization..."
    
    # .wslconfigファイルの作成（Windows側のユーザーディレクトリ）
    local wslconfig_path="/mnt/c/Users/$(whoami)/.wslconfig"
    if [[ ! -f "$wslconfig_path" ]] && [[ -d "/mnt/c/Users/$(whoami)" ]]; then
        log_info "Creating .wslconfig for performance optimization"
        cat > "$wslconfig_path" << 'EOF'
[wsl2]
# メモリ使用量を制限 (8GB)
memory=8GB

# スワップサイズを制限
swap=2GB

# プロセッサ数を制限
processors=4

# ネットワーク設定
localhostForwarding=true

# I/O最適化
pageReporting=false
EOF
        log_success "Created .wslconfig at $wslconfig_path"
    fi
    
    log_success "WSL performance optimization completed"
}

# 日本語入力設定（fcitx5-mozc - WSLg対応）
setup_japanese_input() {
    log_info "Setting up Japanese input (fcitx5-mozc for WSLg)..."

    # fcitx5がインストール済みかチェック
    if command -v fcitx5 >/dev/null 2>&1; then
        log_info "fcitx5 is already installed, checking for updates..."
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm fcitx5 fcitx5-mozc fcitx5-gtk fcitx5-qt fcitx5-configtool
        fi
        log_success "Japanese input setup completed (already installed)"
        return 0
    fi

    # パッケージマネージャーを検出
    if command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        log_info "Installing fcitx5 and fcitx5-mozc for Arch Linux..."
        sudo pacman -S --needed --noconfirm \
            fcitx5 \
            fcitx5-mozc \
            fcitx5-gtk \
            fcitx5-qt \
            fcitx5-configtool
    elif command -v apt >/dev/null 2>&1; then
        # Ubuntu/Debian
        log_info "Installing fcitx5 and mozc for Ubuntu/Debian..."
        sudo apt update
        sudo apt install -y \
            fcitx5 \
            fcitx5-mozc \
            fcitx5-frontend-gtk3 \
            fcitx5-frontend-gtk4 \
            fcitx5-frontend-qt5 \
            fcitx5-config-qt
    else
        log_warning "Unsupported package manager. Please install fcitx5 manually."
        return 1
    fi

    # 日本語フォントインストール
    log_info "Installing Japanese fonts..."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm noto-fonts-cjk adobe-source-han-sans-jp-fonts
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install -y fonts-noto-cjk fonts-noto-cjk-extra
    fi

    log_success "Japanese input setup completed"
    log_info "Please restart your WSL session to use Japanese input"
}

# WSL固有環境変数の設定
setup_wsl_environment() {
    log_info "Setting up WSL environment variables..."

    # WSL固有の環境変数設定ファイル
    local wsl_env_file="${HOME}/.config/wsl/environment"
    mkdir -p "$(dirname "$wsl_env_file")"

    cat > "$wsl_env_file" << 'EOF'
# WSL固有環境変数
export WSL_ENV=1
export DISPLAY=:0.0

# Windows統合パス
export WIN_HOME="/mnt/c/Users/$(whoami)"
export WIN_DESKTOP="$WIN_HOME/Desktop"
export WIN_DOCUMENTS="$WIN_HOME/Documents"
export WIN_DOWNLOADS="$WIN_HOME/Downloads"

# クリップボード統合
if command -v win32yank >/dev/null 2>&1; then
    export CLIPBOARD_COPY="win32yank -i"
    export CLIPBOARD_PASTE="win32yank -o"
elif command -v clip.exe >/dev/null 2>&1; then
    export CLIPBOARD_COPY="clip.exe"
fi

# 日本語入力設定（fcitx5 for WSLg）
if command -v fcitx5 >/dev/null 2>&1; then
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx

    # fcitx5 自動起動（WSLg対応）
    # デーモンが既に動いている場合は再起動しない
    if ! pgrep -x fcitx5 >/dev/null; then
        fcitx5 -d --replace &>/dev/null &
    fi
fi
EOF

    log_success "WSL environment setup completed"
    log_info "Environment file created at: $wsl_env_file"
    log_info "Add this to your ~/.zshrc or ~/.bashrc:"
    log_info "  source \"~/.config/wsl/environment\""
}

# メイン実行
main() {
    setup_windows_integration
    setup_wsl_optimization
    setup_japanese_input
    setup_wsl_environment

    log_success "WSL enhancements setup completed successfully"
    log_info "Please restart your WSL session to apply all changes"
}

# スクリプトが直接実行された場合のみmainを呼び出し
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi