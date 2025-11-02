#!/usr/bin/env bash
# =============================================
# IPアドレス取得スクリプト（クロスプラットフォーム対応）
# =============================================

set -euo pipefail

# OS判定
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: routeコマンドでデフォルトインターフェースを取得し、そのIPアドレスを取得
  route -n get default 2>/dev/null | grep 'interface:' | awk '{print $2}' | xargs ipconfig getifaddr 2>/dev/null || echo 'N/A'
else
  # Linux: ip routeコマンドでIPアドレスを取得
  ip route get 1 2>/dev/null | awk '{print $7}' || echo 'N/A'
fi
