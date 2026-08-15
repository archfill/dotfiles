### Pure Powerline - Catppuccin Mocha の軽量セグメント表示

# Pureの非同期Git処理を維持し、表示テンプレートだけをPowerline形式へ
# 置き換える。外部コマンドはプロンプト描画時に実行しない。
typeset -g PURE_POWERLINE_SURFACE0='#313244'
typeset -g PURE_POWERLINE_BLUE='#89b4fa'
typeset -g PURE_POWERLINE_MAUVE='#cba6f7'
typeset -g PURE_POWERLINE_MANTLE='#181825'
typeset -g PURE_POWERLINE_TEXT='#cdd6f4'
typeset -g PURE_POWERLINE_RED='#f38ba8'
typeset -g PURE_POWERLINE_SEPARATOR=''

case "$OSTYPE" in
  darwin*)
    typeset -g PURE_POWERLINE_OS_ICON=''
    ;;
  linux*)
    typeset -g PURE_POWERLINE_OS_ICON=''
    ;;
  msys* | cygwin*)
    typeset -g PURE_POWERLINE_OS_ICON=''
    ;;
  freebsd*)
    typeset -g PURE_POWERLINE_OS_ICON=''
    ;;
  *)
    typeset -g PURE_POWERLINE_OS_ICON=''
    ;;
esac

prompt_pure_powerline_setup() {
  # Pureが使用するpsvar:
  # 14=Git branch, 15=dirty, 16=action, 17=arrows, 18=stash,
  # 20=virtualenv。
  setopt prompt_subst

  PROMPT='%K{$PURE_POWERLINE_SURFACE0}%F{$PURE_POWERLINE_TEXT} ${PURE_POWERLINE_OS_ICON} '
  PROMPT+='%K{$PURE_POWERLINE_BLUE}%F{$PURE_POWERLINE_SURFACE0}${PURE_POWERLINE_SEPARATOR}'
  PROMPT+='%F{$PURE_POWERLINE_MANTLE} %~ '

  # Gitセグメントはbranchが取得できた時だけ表示する。
  PROMPT+='%(14V.%K{$PURE_POWERLINE_MAUVE}%F{$PURE_POWERLINE_BLUE}${PURE_POWERLINE_SEPARATOR}%F{$PURE_POWERLINE_MANTLE} %14v%(15V.%15v.)%(16V. %16v.)%(17V. %17v.)%(18V. %18v.) .)'

  # 最後の背景色から通常のターミナル背景へ戻す。
  PROMPT+='%k%(14V.%F{$PURE_POWERLINE_MAUVE}.%F{$PURE_POWERLINE_BLUE})${PURE_POWERLINE_SEPARATOR}%f'
  PROMPT+=$'\n'

  # Pure標準と同じくvirtualenvを入力プロンプトの直前に表示する。
  PROMPT+='%(20V.%F{$prompt_pure_colors[virtualenv]}%20v%f .)'
  PROMPT+='%(?.%F{$PURE_POWERLINE_MAUVE}.%F{$PURE_POWERLINE_RED})${prompt_pure_state[prompt]}%f '
}
