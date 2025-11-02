#!/usr/bin/env bash

set -euo pipefail

# root と home のディスク使用状況を取得
disk_data=$(df -h / /home 2>/dev/null | awk 'NR>1 {print $6,$3,$2,$5}')

# root と home の情報を解析
root_info=$(echo "$disk_data" | grep "^/ ")
home_info=$(echo "$disk_data" | grep "^/home ")

# root の情報を取得
read -r _ root_used root_total root_percent <<< "$root_info"
root_percent_num="${root_percent%\%}"

# home の情報を取得
read -r _ home_used home_total home_percent <<< "$home_info"
home_percent_num="${home_percent%\%}"

# 最大使用率を取得（状態クラス決定用）
max_percent=$((root_percent_num > home_percent_num ? root_percent_num : home_percent_num))

# 状態クラスを決定
if [ "$max_percent" -ge 90 ]; then
    class="critical"
elif [ "$max_percent" -ge 80 ]; then
    class="warning"
else
    class="normal"
fi

# JSON形式で出力（1行で）
printf '{"text":"/ %s%% /home %s%%","tooltip":"ディスク使用量\\n\\n/ (root)\\n  使用: %s / %s\\n  使用率: %s\\n\\n/home\\n  使用: %s / %s\\n  使用率: %s","percentage":%s,"class":"%s"}\n' \
    "$root_percent_num" "$home_percent_num" \
    "$root_used" "$root_total" "$root_percent" \
    "$home_used" "$home_total" "$home_percent" \
    "$max_percent" "$class"
