#!/usr/bin/env bash

# verify-links.sh
# シンボリックリンクの状態を確認・検証するスクリプト

set -euo pipefail

source "$(dirname "$0")/lib/config_loader.sh"

setup_error_handling

# 設定
TARGET_DIR="${HOME}"
SHOW_ALL=false
SHOW_BROKEN_ONLY=false
SHOW_DOTFILES_ONLY=false
OUTPUT_FORMAT="human"

# 使用方法
usage() {
    cat << EOF
使用方法: $(basename "$0") [オプション]

オプション:
    -a, --all               全てのシンボリックリンクを表示
    -b, --broken-only       壊れたシンボリックリンクのみ表示
    -d, --dotfiles-only     dotfiles関連のリンクのみ表示
    -t, --target DIR        対象ディレクトリを指定 (デフォルト: $HOME)
    -f, --format FORMAT     出力形式 (human|json|csv) デフォルト: human
    -h, --help              このヘルプを表示

説明:
    シンボリックリンクの状態を確認し、以下の情報を表示します：
    - リンクの状態（正常/壊れている）
    - リンク先パス
    - dotfiles関連かどうか
    - ファイルサイズ・更新日時

例:
    $(basename "$0")                    # 概要表示
    $(basename "$0") --all              # 全リンク表示
    $(basename "$0") --broken-only      # 壊れたリンクのみ
    $(basename "$0") --dotfiles-only    # dotfiles関連のみ
    $(basename "$0") --format json      # JSON形式で出力
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            SHOW_ALL=true
            shift
            ;;
        -b|--broken-only)
            SHOW_BROKEN_ONLY=true
            shift
            ;;
        -d|--dotfiles-only)
            SHOW_DOTFILES_ONLY=true
            shift
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            case $OUTPUT_FORMAT in
                human|json|csv) ;;
                *)
                    log_error "無効な出力形式: $OUTPUT_FORMAT"
                    usage
                    exit 1
                    ;;
            esac
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

# シンボリックリンク情報を取得
get_symlink_info() {
    local symlink="$1"
    local target
    local status
    local size=""
    local mtime=""
    local is_dotfiles=false

    # リンク先を取得
    target=$(readlink "$symlink" 2>/dev/null || echo "<読み取り不可>")

    # 状態確認
    if [[ -e "$symlink" ]]; then
        status="正常"
        # ファイル情報取得
        if [[ -f "$symlink" ]]; then
            size=$(stat -f%z "$symlink" 2>/dev/null || echo "不明")
            mtime=$(stat -f%Sm -t%Y-%m-%d\ %H:%M:%S "$symlink" 2>/dev/null || echo "不明")
        fi
    else
        status="壊れている"
    fi

    # dotfiles関連かチェック
    if [[ "$target" == *"dotfiles"* ]] || [[ "$target" == *"/.dotfiles"* ]]; then
        is_dotfiles=true
    fi

    # JSON形式で情報を出力
    cat << EOF
{
  "symlink": "$symlink",
  "target": "$target",
  "status": "$status",
  "size": "$size",
  "mtime": "$mtime",
  "is_dotfiles": $is_dotfiles
}
EOF
}

# フィルタリング
should_show_link() {
    local info="$1"
    local status
    local is_dotfiles

    status=$(echo "$info" | jq -r '.status')
    is_dotfiles=$(echo "$info" | jq -r '.is_dotfiles')

    # 壊れたリンクのみ表示
    if [[ "$SHOW_BROKEN_ONLY" == true ]] && [[ "$status" != "壊れている" ]]; then
        return 1
    fi

    # dotfiles関連のみ表示
    if [[ "$SHOW_DOTFILES_ONLY" == true ]] && [[ "$is_dotfiles" != "true" ]]; then
        return 1
    fi

    return 0
}

# 人間可読形式で出力
format_human() {
    local info="$1"
    local symlink target status size mtime is_dotfiles

    symlink=$(echo "$info" | jq -r '.symlink')
    target=$(echo "$info" | jq -r '.target')
    status=$(echo "$info" | jq -r '.status')
    size=$(echo "$info" | jq -r '.size')
    mtime=$(echo "$info" | jq -r '.mtime')
    is_dotfiles=$(echo "$info" | jq -r '.is_dotfiles')

    # 状態に応じて色付け
    local status_color=""
    case $status in
        "正常")
            status_color="\033[32m✅ $status\033[0m"
            ;;
        "壊れている")
            status_color="\033[31m❌ $status\033[0m"
            ;;
    esac

    printf "📁 %s\n" "$symlink"
    printf "   状態: %s\n" "$status_color"
    printf "   参照先: %s\n" "$target"

    if [[ "$is_dotfiles" == "true" ]]; then
        printf "   種別: \033[34m🔧 dotfiles関連\033[0m\n"
    else
        printf "   種別: その他\n"
    fi

    if [[ "$size" != "不明" && "$size" != "" ]]; then
        printf "   サイズ: %s bytes\n" "$size"
    fi

    if [[ "$mtime" != "不明" && "$mtime" != "" ]]; then
        printf "   更新日時: %s\n" "$mtime"
    fi

    printf "\n"
}

# CSV形式で出力
format_csv() {
    local info="$1"
    local symlink target status size mtime is_dotfiles

    symlink=$(echo "$info" | jq -r '.symlink')
    target=$(echo "$info" | jq -r '.target')
    status=$(echo "$info" | jq -r '.status')
    size=$(echo "$info" | jq -r '.size')
    mtime=$(echo "$info" | jq -r '.mtime')
    is_dotfiles=$(echo "$info" | jq -r '.is_dotfiles')

    printf '"%s","%s","%s","%s","%s","%s"\n' \
        "$symlink" "$target" "$status" "$size" "$mtime" "$is_dotfiles"
}

# 統計情報を計算
calculate_stats() {
    local infos="$1"
    local total_count=0
    local broken_count=0
    local dotfiles_count=0

    while IFS= read -r info; do
        if [[ -n "$info" ]]; then
            local status is_dotfiles
            status=$(echo "$info" | jq -r '.status')
            is_dotfiles=$(echo "$info" | jq -r '.is_dotfiles')

            ((total_count++))

            if [[ "$status" == "壊れている" ]]; then
                ((broken_count++))
            fi

            if [[ "$is_dotfiles" == "true" ]]; then
                ((dotfiles_count++))
            fi
        fi
    done <<< "$infos"

    cat << EOF
{
  "total_symlinks": $total_count,
  "broken_symlinks": $broken_count,
  "dotfiles_symlinks": $dotfiles_count,
  "healthy_symlinks": $((total_count - broken_count))
}
EOF
}

# メイン処理
main() {
    if [[ ! -d "$TARGET_DIR" ]]; then
        log_error "対象ディレクトリが存在しません: $TARGET_DIR"
        exit 1
    fi

    log_info "=== シンボリックリンク状態確認 ==="
    log_info "対象ディレクトリ: $TARGET_DIR"

    # シンボリックリンクを検索
    local symlinks
    symlinks=$(find "$TARGET_DIR" -type l 2>/dev/null | head -100)  # 最大100件に制限

    if [[ -z "$symlinks" ]]; then
        log_info "シンボリックリンクが見つかりませんでした"
        return 0
    fi

    # 情報収集
    local all_infos=()
    local filtered_infos=()

    while IFS= read -r symlink; do
        if [[ -n "$symlink" ]]; then
            local info
            info=$(get_symlink_info "$symlink")
            all_infos+=("$info")

            if should_show_link "$info"; then
                filtered_infos+=("$info")
            fi
        fi
    done <<< "$symlinks"

    # 統計情報
    local stats
    stats=$(printf '%s\n' "${all_infos[@]}" | calculate_stats "$(printf '%s\n' "${all_infos[@]}")")

    # 出力形式に応じて表示
    case $OUTPUT_FORMAT in
        json)
            echo "{"
            echo '  "statistics": '"$stats"','
            echo '  "symlinks": ['
            local first=true
            for info in "${filtered_infos[@]}"; do
                if [[ "$first" == true ]]; then
                    first=false
                else
                    echo ","
                fi
                echo "    $info" | tr -d '\n'
            done
            echo
            echo "  ]"
            echo "}"
            ;;
        csv)
            echo "symlink,target,status,size,mtime,is_dotfiles"
            for info in "${filtered_infos[@]}"; do
                format_csv "$info"
            done
            ;;
        human)
            # 統計情報表示
            local total broken dotfiles healthy
            total=$(echo "$stats" | jq -r '.total_symlinks')
            broken=$(echo "$stats" | jq -r '.broken_symlinks')
            dotfiles=$(echo "$stats" | jq -r '.dotfiles_symlinks')
            healthy=$(echo "$stats" | jq -r '.healthy_symlinks')

            printf "\n📊 統計情報:\n"
            printf "   全体: %d 個\n" "$total"
            printf "   正常: \033[32m%d 個\033[0m\n" "$healthy"
            printf "   壊れている: \033[31m%d 個\033[0m\n" "$broken"
            printf "   dotfiles関連: \033[34m%d 個\033[0m\n" "$dotfiles"
            printf "\n"

            # 詳細表示（条件に応じて）
            if [[ "$SHOW_ALL" == true ]] || [[ "$SHOW_BROKEN_ONLY" == true ]] || [[ "$SHOW_DOTFILES_ONLY" == true ]]; then
                printf "📋 詳細情報:\n\n"
                for info in "${filtered_infos[@]}"; do
                    format_human "$info"
                done
            else
                if [[ "$broken" -gt 0 ]]; then
                    printf "\033[33m⚠️  壊れたリンクがあります。詳細は --broken-only オプションで確認してください\033[0m\n"
                fi
                printf "全ての詳細を表示するには --all オプションを使用してください\n"
            fi
            ;;
    esac
}

# スクリプト実行
main "$@"