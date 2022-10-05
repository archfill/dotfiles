vim.fn["skkeleton#config"]({
  globalJisyo = "~/git/skk/SKK-JISYO.L",
  useSkkServer = true,
  skkServerHost = "192.168.0.100",
  eggLikeNewline = true,
})

vim.cmd [[
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
]]
