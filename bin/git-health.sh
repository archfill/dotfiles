#!/usr/bin/env bash
#
# git-health: ghq管理リポジトリの健全性チェック
#
# 使用方法:
#   git-health           全リポジトリをチェック
#   git-health --quiet   問題リポジトリのパスのみ表示
#   git-health -q        同上
#   git-health --help    ヘルプ表示
#

set -euo pipefail

# カラー定義
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# グローバル変数
QUIET_MODE=false
TOTAL_REPOS=0
PROBLEM_REPOS=0

# ヘルプ表示
show_help() {
    cat << 'EOF'
git-health - ghq管理リポジトリの健全性チェック

使用方法:
  git-health [オプション]

オプション:
  -q, --quiet    問題のあるリポジトリのパスのみ表示
  -h, --help     このヘルプを表示

チェック項目:
  - 未コミット変更（変更/未追跡ファイル）
  - 未プッシュコミット（リモートより先行）
  - リモート設定の表示

例:
  git-health              # 全リポジトリをチェック
  git-health --quiet      # 問題リポジトリのパスのみ
  git-health -q | xargs   # パイプで他コマンドに渡す
EOF
}

# 未コミット変更をチェック
check_uncommitted() {
    local repo_path="$1"
    local status
    status=$(git -C "$repo_path" status --porcelain 2>/dev/null) || return 1

    if [[ -z "$status" ]]; then
        echo ""
        return 0
    fi

    local modified=0 untracked=0 staged=0
    while IFS= read -r line; do
        local index_status="${line:0:1}"
        local worktree_status="${line:1:1}"

        # ステージング済み
        if [[ "$index_status" =~ [MADRC] ]]; then
            ((staged++))
        fi
        # 変更あり（未ステージ）
        if [[ "$worktree_status" =~ [MD] ]]; then
            ((modified++))
        fi
        # 未追跡
        if [[ "$index_status" == "?" ]]; then
            ((untracked++))
        fi
    done <<< "$status"

    local result=""
    if [[ $staged -gt 0 ]]; then
        result+="${staged}ファイルステージ済"
    fi
    if [[ $modified -gt 0 ]]; then
        [[ -n "$result" ]] && result+=", "
        result+="${modified}ファイル変更"
    fi
    if [[ $untracked -gt 0 ]]; then
        [[ -n "$result" ]] && result+=", "
        result+="${untracked}ファイル未追跡"
    fi

    echo "$result"
}

# 未プッシュコミットをチェック
check_unpushed() {
    local repo_path="$1"

    # upstreamが設定されていない場合
    if ! git -C "$repo_path" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        # リモートが存在するかチェック
        local has_remote
        has_remote=$(git -C "$repo_path" remote 2>/dev/null | head -1) || true
        if [[ -n "$has_remote" ]]; then
            echo "upstream未設定"
        else
            echo ""
        fi
        return 0
    fi

    local count
    count=$(git -C "$repo_path" rev-list '@{u}..HEAD' --count 2>/dev/null) || count=0

    if [[ "$count" -gt 0 ]]; then
        echo "${count}コミット先行"
    else
        echo ""
    fi
}

# リモート情報を取得
get_remote_info() {
    local repo_path="$1"
    local remotes
    remotes=$(git -C "$repo_path" remote -v 2>/dev/null | grep "(fetch)" | head -1 || true)

    if [[ -z "$remotes" ]]; then
        echo "リモート未設定"
        return 0
    fi

    local name url
    name=$(echo "$remotes" | awk '{print $1}')
    url=$(echo "$remotes" | awk '{print $2}')

    echo "${name} -> ${url}"
}

# リポジトリの問題を表示
print_repo_issues() {
    local repo_path="$1"
    local uncommitted="$2"
    local unpushed="$3"
    local remote_info="$4"

    if $QUIET_MODE; then
        echo "$repo_path"
        return
    fi

    # パスを短縮表示（$HOME を ~ に）
    local display_path="${repo_path/$HOME/~}"

    echo -e "${COLOR_YELLOW}⚠ ${display_path}${COLOR_RESET}"

    if [[ -n "$uncommitted" ]]; then
        echo -e "  未コミット: ${uncommitted}"
    fi

    if [[ -n "$unpushed" ]]; then
        echo -e "  未プッシュ: ${unpushed}"
    fi

    echo -e "  リモート: ${remote_info}"
    echo ""
}

# メイン処理
main() {
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -q|--quiet)
                QUIET_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "不明なオプション: $1" >&2
                show_help >&2
                exit 1
                ;;
        esac
    done

    # ghqの存在確認
    if ! command -v ghq >/dev/null 2>&1; then
        echo -e "${COLOR_RED}エラー: ghqがインストールされていません${COLOR_RESET}" >&2
        exit 1
    fi

    # ghq rootの取得
    local ghq_root
    ghq_root=$(ghq root 2>/dev/null) || {
        echo -e "${COLOR_RED}エラー: ghq rootの取得に失敗しました${COLOR_RESET}" >&2
        exit 1
    }

    # リポジトリ一覧を取得
    local repos
    repos=$(ghq list --full-path 2>/dev/null) || {
        echo -e "${COLOR_RED}エラー: ghq listの取得に失敗しました${COLOR_RESET}" >&2
        exit 1
    }

    if [[ -z "$repos" ]]; then
        if ! $QUIET_MODE; then
            echo "ghq管理下のリポジトリがありません"
        fi
        exit 0
    fi

    TOTAL_REPOS=$(echo "$repos" | wc -l | tr -d ' ')

    if ! $QUIET_MODE; then
        echo -e "${COLOR_BLUE}📦 ${TOTAL_REPOS}リポジトリをチェック中...${COLOR_RESET}"
        echo ""
    fi

    # 各リポジトリをチェック
    while IFS= read -r repo_path; do
        [[ -z "$repo_path" ]] && continue
        [[ ! -d "$repo_path/.git" ]] && continue

        local uncommitted unpushed remote_info has_problem=false

        uncommitted=$(check_uncommitted "$repo_path")
        unpushed=$(check_unpushed "$repo_path")
        remote_info=$(get_remote_info "$repo_path")

        # 問題があるかチェック
        if [[ -n "$uncommitted" ]] || [[ -n "$unpushed" && "$unpushed" != "" ]]; then
            has_problem=true
        fi

        if $has_problem; then
            ((PROBLEM_REPOS++)) || true
            print_repo_issues "$repo_path" "$uncommitted" "$unpushed" "$remote_info"
        fi
    done <<< "$repos"

    # サマリー表示
    if ! $QUIET_MODE; then
        local healthy_repos=$((TOTAL_REPOS - PROBLEM_REPOS))
        if [[ $PROBLEM_REPOS -eq 0 ]]; then
            echo -e "${COLOR_GREEN}✓ ${TOTAL_REPOS}/${TOTAL_REPOS} リポジトリ正常${COLOR_RESET}"
        else
            echo -e "${COLOR_GREEN}✓ ${healthy_repos}/${TOTAL_REPOS} リポジトリ正常${COLOR_RESET}"
        fi
    fi

    # 問題があった場合は終了コード1
    if [[ $PROBLEM_REPOS -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
