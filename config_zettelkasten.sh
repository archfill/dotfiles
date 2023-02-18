#!/usr/bin/env bash
# このshellのサンプル
# https://gist.github.com/kawarimidoll/371ee1741897608b945c8338b7a75ac3

usage() {
  cat << EOS >&2
config_zettelkasten.sh

USAGE:
  bash config_zettelkasten.sh [options] <arg1> [arg2]

OPTIONS:
  -n, --nextcloud       add config nextcloud path memolist.
  -h, --help            Show this help message.

EOS
}

invalid() {
  usage 1>&2
  echo "$@" 1>&2
  exit 1
}

ARGS=()
while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      # ヘルプ
      usage
      exit 0
      ;;
    -n | --nextcloud)
      if [[ -n "$OPT_N" ]]; then
        invalid "Duplicated 'option-n'."
        exit 1
      fi
      OPT_N=1
      ;;
    -*)
      invalid "Illegal option -- '$(echo $1 | sed 's/^-*//')'."
      exit 1
      ;;
    *)
      ARGS=("${ARGS[@]}" "$1")
      ;;
  esac
  shift
done

# 引数チェック
if [[ "${#ARGS[@]}" -gt 0 ]]; then
  # 引数が未設定の場合のみ正常動作する
  # オプションのみ許容
  invalid "not arguments rerun."
  exit 1
fi

# 以下、メイン処理
MEMOLIST_DIR=~/zettelkasten

if [[ ! -z "$OPT_N" ]]; then
  # optionのnextcloudが指定されていたら実施
  echo "nextcloud config."

  if [[ -d $MEMOLIST_DIR ]]; then
    # ディレクトリ ~/.memolist/memo が存在する場合
    unlink $MEMOLIST_DIR
    rm -rf $MEMOLIST_DIR
  fi
  ln -sf ~/Nextcloud/Notes/zettelkasten $MEMOLIST_DIR
else
  echo "local config."
  if [[ ! -d $MEMOLIST_DIR ]]; then
    # ディレクトリ ~/.memolist が存在しない場合
    mkdir -p $MEMOLIST_DIR
  fi
fi

echo "finish."
