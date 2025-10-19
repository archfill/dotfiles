#!/bin/bash
# Ghostty tmux session manager
# 既存のtmuxセッションに接続、または新規作成

SESSION_NAME="main"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # 既存セッションに接続
    exec tmux attach-session -t "$SESSION_NAME"
else
    # 新規セッション作成
    exec tmux new-session -s "$SESSION_NAME"
fi
