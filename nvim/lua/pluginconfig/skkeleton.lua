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
]])
