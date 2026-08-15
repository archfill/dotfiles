### Pure - minimal zsh prompt (Sheldon で読み込む前に設定)
PURE_GIT_PULL=0
source "$ZRCDIR/prompt.zsh"

### Sheldon - zsh plugin manager (Pure を含め Nix の programs.sheldon で管理)
_sheldon_source="$(sheldon source)"

# Home Managerはplugins.tomlを更新するが、既存のSheldon lockは更新しない。
# Pureがlockにない初回だけ再生成し、以降のシェル起動では通常経路へ戻す。
if [[ $_sheldon_source != *'/sindresorhus/pure/'* ]]; then
  if _sheldon_relocked_source="$(sheldon source --relock)"; then
    _sheldon_source=$_sheldon_relocked_source
  fi
fi

eval "$_sheldon_source"
unset _sheldon_source _sheldon_relocked_source

# Sheldon設定の反映前はPureが未ロードなので、通常のプロンプトを維持する。
(( $+functions[prompt_pure_precmd] )) && prompt_pure_powerline_setup
