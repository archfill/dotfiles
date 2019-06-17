function! hook#source#denite#load() abort
  let s:denite_win_width_percent = 0.85
  let s:denite_win_height_percent = 0.7

  " jj で denite/insert を抜けるようにする
  call denite#custom#map('insert', 'jj', '<denite:enter_mode:normal>')
  call denite#custom#option('default', {
      \ 'auto_accel': v:true,
      \ 'prompt': '>',
      \ 'source_names': 'short',
      \ })
  
  " Change denite default options
  " neovim v0.4.0以降有効にする
  " call denite#custom#option('default', {
  "   \ 'split': 'floating',
  "   \ 'winwidth': float2nr(&columns * s:denite_win_width_percent),
  "   \ 'wincol': float2nr((&columns - (&columns * s:denite_win_width_percent)) / 2),
  "   \ 'winheight': float2nr(&lines * s:denite_win_height_percent),
  "   \ 'winrow': float2nr((&lines - (&lines * s:denite_win_height_percent)) / 2),
  "   \ })

  if executable('rg')
    call denite#custom#var('file/rec', 'command',
          \ ['rg', '-uu', '--files', '--glob',  '!.git'])
    call denite#custom#var('grep', 'command', ['rg', '--threads', '1'])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'final_opts', [])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'default_opts',
          \ ['--vimgrep', '--no-heading'])
  else
    call denite#custom#var('file/rec', 'command',
          \ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  endif
endfunction

