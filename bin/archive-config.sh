#!/usr/bin/env bash

# archive-config.sh
# 設定ファイルを安全にアーカイブ化するスクリプト

set -euo pipefail

source "$(dirname "$0")/lib/config_loader.sh"

setup_error_handling

# 設定
ARCHIVE_BRANCH_PREFIX="archive"
BACKUP_DIR="${HOME}/.dotfiles-backup"
DRY_RUN=false

# 使用方法
usage() {
    cat << EOF
使用方法: $(basename "$0") [オプション] <設定名> [理由]

引数:
    設定名          アーカイブする設定の名前（例: yabai-skhd）
    理由            アーカイブする理由（省略可）

オプション:
    -d, --dry-run   実際の操作は行わず、実行内容のみ表示
    -b, --backup    Gitブランチ作成前にローカルバックアップも作成
    -h, --help      このヘルプを表示

説明:
    設定ファイルの削除前に、以下の処理を行います：
    1. アーカイブブランチの作成
    2. 現在の設定状態をコミット
    3. オプションでローカルバックアップ作成
    4. 移行記録の作成

例:
    $(basename "$0") yabai-skhd "Aerospaceに移行のため"
    $(basename "$0") --dry-run nvim-old
    $(basename "$0") --backup hammerspoon "設定見直しのため"
EOF
}

# 引数解析
CONFIG_NAME=""
REASON=""
CREATE_BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -b|--backup)
            CREATE_BACKUP=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            log_error "不明なオプション: $1"
            usage
            exit 1
            ;;
        *)
            if [[ -z "$CONFIG_NAME" ]]; then
                CONFIG_NAME="$1"
            elif [[ -z "$REASON" ]]; then
                REASON="$1"
            else
                log_error "引数が多すぎます"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# 必須引数チェック
if [[ -z "$CONFIG_NAME" ]]; then
    log_error "設定名が指定されていません"
    usage
    exit 1
fi

# デフォルトの理由を設定
if [[ -z "$REASON" ]]; then
    REASON="設定の整理・アーカイブ化"
fi

# Git リポジトリかチェック
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log_error "Git リポジトリ内で実行してください"
        exit 1
    fi
}

# ブランチ名生成
generate_branch_name() {
    local config_name="$1"
    local date
    date=$(date +%Y%m%d)
    echo "${ARCHIVE_BRANCH_PREFIX}/${config_name}-${date}"
}

# ローカルバックアップ作成
create_local_backup() {
    local config_name="$1"
    local backup_path="${BACKUP_DIR}/${config_name}-$(date +%Y%m%d-%H%M%S)"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] ローカルバックアップ作成: $backup_path"
        return 0
    fi

    log_info "ローカルバックアップを作成中: $backup_path"

    # バックアップディレクトリ作成
    mkdir -p "$backup_path"

    # 現在の作業ディレクトリをバックアップ
    if tar -czf "$backup_path/dotfiles-backup.tar.gz" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*.log' \
        -C "$(git rev-parse --show-toplevel)" \
        . 2>/dev/null; then

        log_info "✅ ローカルバックアップ完了: $backup_path/dotfiles-backup.tar.gz"

        # バックアップ情報を記録
        cat > "$backup_path/backup-info.txt" << EOF
バックアップ作成日時: $(date)
設定名: $config_name
理由: $reason
Git コミット: $(git rev-parse HEAD)
Git ブランチ: $(git branch --show-current)
EOF

    else
        log_error "ローカルバックアップの作成に失敗しました"
        return 1
    fi
}

# アーカイブブランチ作成
create_archive_branch() {
    local config_name="$1"
    local reason="$2"
    local branch_name
    branch_name=$(generate_branch_name "$config_name")

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] アーカイブブランチ作成: $branch_name"
        log_info "[DRY RUN] コミットメッセージ: archive($config_name): $reason"
        return 0
    fi

    # 現在のブランチを確認
    local current_branch
    current_branch=$(git branch --show-current)

    log_info "現在のブランチ: $current_branch"

    # 未コミットの変更があるかチェック
    if ! git diff-index --quiet HEAD --; then
        log_warn "未コミットの変更があります。アーカイブ前にコミットすることを推奨します。"
        read -p "続行しますか？ [y/N]: " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "キャンセルされました"
            exit 0
        fi
    fi

    # アーカイブブランチ作成
    log_info "アーカイブブランチを作成中: $branch_name"

    if git checkout -b "$branch_name"; then
        log_info "✅ ブランチ作成完了: $branch_name"
    else
        log_error "ブランチの作成に失敗しました"
        return 1
    fi

    # アーカイブコミット作成
    local commit_message="archive($config_name): $reason

アーカイブ作成日時: $(date)
元ブランチ: $current_branch
アーカイブ理由: $reason

このブランチには削除前の$config_name設定が保存されています。"

    # 全ての変更をステージング（アーカイブのため）
    git add -A

    if git commit -m "$commit_message"; then
        log_info "✅ アーカイブコミット作成完了"
    else
        log_info "新しい変更がないため、現在の状態でアーカイブブランチを作成しました"
    fi

    # 元のブランチに戻る
    git checkout "$current_branch"
    log_info "元のブランチに戻りました: $current_branch"

    # リモートにプッシュ（オプション）
    read -p "アーカイブブランチをリモートにプッシュしますか？ [y/N]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if git push -u origin "$branch_name"; then
            log_info "✅ リモートプッシュ完了"
        else
            log_warn "リモートプッシュに失敗しました（ローカルブランチは作成済み）"
        fi
    fi
}

# 移行記録作成
create_migration_record() {
    local config_name="$1"
    local reason="$2"
    local branch_name
    branch_name=$(generate_branch_name "$config_name")

    local migration_dir="docs/migration"
    local record_file="${migration_dir}/${config_name}-$(date +%Y%m%d).md"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] 移行記録作成: $record_file"
        return 0
    fi

    # ディレクトリ作成
    mkdir -p "$migration_dir"

    # 記録ファイル作成
    cat > "$record_file" << EOF
# $config_name 設定アーカイブ記録

## 基本情報

- **設定名**: $config_name
- **アーカイブ日**: $(date +%Y-%m-%d)
- **実行者**: $(git config user.name) <$(git config user.email)>
- **理由**: $reason

## アーカイブ情報

- **アーカイブブランチ**: \`$branch_name\`
- **元ブランチ**: \`$(git branch --show-current)\`
- **コミットハッシュ**: \`$(git rev-parse HEAD)\`

## 設定概要

<!-- ここにアーカイブした設定の概要を記述 -->

## 移行先・代替手段

<!-- 新しい設定や代替手段について記述 -->

## 復元方法

アーカイブした設定を復元する場合：

\`\`\`bash
# アーカイブブランチをチェックアウト
git checkout $branch_name

# 必要なファイルを現在のブランチにコピー
# （具体的な手順は設定に応じて調整）

# 元のブランチに戻る
git checkout main
\`\`\`

## 注意事項

- このアーカイブは$(date +%Y-%m-%d)時点の設定状態です
- 復元時は現在の設定との競合に注意してください
- 質問がある場合は移行記録の実行者に連絡してください
EOF

    log_info "✅ 移行記録作成完了: $record_file"
}

# メイン処理
main() {
    log_info "=== 設定アーカイブ化スクリプト ==="
    log_info "設定名: $CONFIG_NAME"
    log_info "理由: $REASON"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "DRY RUN モード: 実際の操作は行いません"
    fi

    # Git リポジトリチェック
    check_git_repo

    # 処理実行
    if [[ "$CREATE_BACKUP" == true ]]; then
        create_local_backup "$CONFIG_NAME"
    fi

    create_archive_branch "$CONFIG_NAME" "$REASON"
    create_migration_record "$CONFIG_NAME" "$REASON"

    echo
    log_info "✅ アーカイブ化処理完了"
    log_info "次の手順:"
    log_info "1. 設定ファイルの削除・変更を実行"
    log_info "2. テスト期間を設ける"
    log_info "3. 問題なければ変更をコミット"
    log_info "4. 必要に応じて bin/cleanup-symlinks.sh でリンク清理"
}

# スクリプト実行
main "$@"