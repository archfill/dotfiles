vim.fn["skkeleton#config"]({
	globalJisyo = "~/git/skk/SKK-JISYO.L",
	useSkkServer = true,
	skkServerHost = "192.168.0.100",
	eggLikeNewline = true,
	skkServerPort = 1178,
	skkServerResEnc = "euc-jp",
	skkServerReqEnc = "euc-jp",
})

vim.cmd([[
call skkeleton#register_kanatable('rom', {
  \ 'z-': ['〜'],
  \ 'z.': ['…'],
  \ 'z/': ['・'],
  \ 'zh': ['←'],
  \ 'zj': ['↓'],
  \ 'zk': ['↑'],
  \ 'zl': ['→'],
  \ 'jj': 'escape',
  \ "z\<Space>": ["\u3000", ''],
  \ })

" 例: <C-l>で全角モードに入れるようにします
" call add(g:skkeleton#mapped_keys, '<C-l>')
" call skkeleton#register_keymap('input', '<C-l>', 'zenkaku')

" cocot36plus(30% keyborad)用
" HHKBだと無効化
call skkeleton#register_keymap('input', '/', 'henkanPoint')
call skkeleton#register_keymap('input', ';', 'abbrev')
]])
