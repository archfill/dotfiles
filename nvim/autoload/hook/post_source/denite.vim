function! hook#post_source#denite#load() abort
  call denite#custom#var('file/rec', 'command',
\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  call denite#custom#var('grep', 'command',
\ ['ag', '--nogroup', '--nocolor', '--smart-case'])
  call denite#custom#var('grep', 'default_opts', [])
  call denite#custom#var('grep', 'recursive_opts', [])
endfunction

