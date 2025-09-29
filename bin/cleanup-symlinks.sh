#!/usr/bin/env bash

# cleanup-symlinks.sh
# 壊れたシンボリックリンクを検出・削除するスクリプト

set -euo pipefail

source "$(dirname "$0")/lib/config_loader.sh"

setup_error_handling

# 設定
DRY_RUN=false
TARGET_DIR="${HOME}"
PROTECTED_PATHS=(
    "${HOME}/.git"
    "${HOME}/.ssh"
    "${HOME}/.gnupg"
    "${HOME}/Library"
    "${HOME}/Applications"
)

# 使用方法
usage() {
    cat << EOF
使用方法: $(basename "$0") [オプション]

オプション:
    -d, --dry-run       実際の削除は行わず、削除対象のみ表示
    -t, --target DIR    対象ディレクトリを指定 (デフォルト: $HOME)
    -h, --help          このヘルプを表示

説明:
    壊れたシンボリックリンクを検出し、安全に削除します。
    保護されたパスは自動的に除外されます。

例:
    $(basename "$0") --dry-run          # 削除対象を確認
    $(basename "$0")                    # 実際に削除実行
    $(basename "$0") -t ~/.config       # ~/.config のみ対象
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "不明なオプション: $1"
            usage
            exit 1
            ;;
    esac
done

# パスが保護されているかチェック
is_protected_path() {
    local path="$1"
    for protected in "${PROTECTED_PATHS[@]}"; do
        if [[ "$path" == "$protected"* ]]; then
            return 0
        fi
    done
    return 1
}

# 壊れたシンボリックリンクを検出
find_broken_symlinks() {
    local target_dir="$1"

    if [[ ! -d "$target_dir" ]]; then
        log_error "対象ディレクトリが存在しません: $target_dir"
        return 1
    fi

    log_info "壊れたシンボリックリンクを検索中: $target_dir"

    # GNU find を使用（macOS の場合は gfind）
    local find_cmd="find"
    if command -v gfind >/dev/null 2>&1; then
        find_cmd="gfind"
    fi

    # 壊れたシンボリックリンクを検出
    # -xtype l: リンク先が存在しないシンボリックリンク
    # -not -path: 保護されたパスを除外
    local exclude_args=()
    for protected in "${PROTECTED_PATHS[@]}"; do
        exclude_args+=(-not -path "${protected}*")
    done

    "$find_cmd" "$target_dir" -xtype l "${exclude_args[@]}" 2>/dev/null || {
        # -xtype が使えない場合のフォールバック
        log_warn "-xtype オプションが使用できません。代替方法を使用します。"
        "$find_cmd" "$target_dir" -type l "${exclude_args[@]}" -exec test ! -e {} \; -print 2>/dev/null
    }
}

# シンボリックリンクの詳細情報を表示
show_symlink_info() {
    local symlink="$1"
    local target
    target=$(readlink "$symlink" 2>/dev/null || echo "<読み取り不可>")

    printf "  リンク: %s\n" "$symlink"
    printf "  参照先: %s\n" "$target"

    # dotfiles リポジトリ内のファイルかチェック
    if [[ "$target" == *"dotfiles"* ]]; then
        printf "  種別: dotfiles関連\n"
    else
        printf "  種別: その他\n"
    fi
    printf "\n"
}

# メイン処理
main() {
    log_info "=== 壊れたシンボリックリンク清理スクリプト ==="

    if [[ "$DRY_RUN" == true ]]; then
        log_info "DRY RUN モード: 実際の削除は行いません"
    fi

    # 壊れたシンボリックリンクを検出
    local broken_links
    broken_links=$(find_broken_symlinks "$TARGET_DIR")

    if [[ -z "$broken_links" ]]; then
        log_info "✅ 壊れたシンボリックリンクは見つかりませんでした"
        return 0
    fi

    # 削除対象を表示
    log_warn "⚠️  以下の壊れたシンボリックリンクが見つかりました:"
    echo

    local count=0
    while IFS= read -r symlink; do
        if [[ -n "$symlink" ]]; then
            show_symlink_info "$symlink"
            ((count++))
        fi
    done <<< "$broken_links"

    log_info "合計: $count 個の壊れたシンボリックリンク"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "実際に削除するには --dry-run オプションを外して実行してください"
        return 0
    fi

    # 削除確認
    echo
    read -p "これらのシンボリックリンクを削除しますか？ [y/N]: " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "キャンセルされました"
        return 0
    fi

    # 実際に削除
    log_info "削除を実行中..."
    local deleted_count=0

    while IFS= read -r symlink; do
        if [[ -n "$symlink" ]]; then
            if is_protected_path "$symlink"; then
                log_warn "保護されたパスのためスキップ: $symlink"
                continue
            fi

            if rm "$symlink" 2>/dev/null; then
                log_info "削除: $symlink"
                ((deleted_count++))
            else
                log_error "削除失敗: $symlink"
            fi
        fi
    done <<< "$broken_links"

    log_info "✅ 削除完了: $deleted_count 個のシンボリックリンクを削除しました"
}

# スクリプト実行
main "$@"