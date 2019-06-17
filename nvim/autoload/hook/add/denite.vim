function! hook#add#denite#load() abort
  nnoremap <silent> [window]t :<C-u>Denite filetype<CR>
  nnoremap [window]p :<C-u>Denite file/rec<CR>
  nnoremap [window]j :<C-u>Denite line<CR>
  nnoremap <silent> [Window]g :<C-u>Denite -buffer-name=search
    \ -no-empty -mode=normal grep<CR>
  nnoremap [window]] :<C-u>DeniteCursorWord grep<CR>
  nnoremap [window]u :<C-u>Denite file/mru<CR>
  nnoremap [window]y :<C-u>Denite neoyank<CR>
  nnoremap [window]r :<C-u>Denite -resume<CR>
  nnoremap [window]; :<C-u>Denite -resume -immediately -select=+1<CR>
  nnoremap [window]- :<C-u>Denite -resume -immediately -select=-1<CR>
  nnoremap [window]d :<C-u>call denite#start([{'name': 'file/rec', 'args': ['~/dotfiles']}])<CR>
  nnoremap ml :<C-u>call denite#start([{'name': 'file/rec', 'args': [g:memolist_path]}])<CR>
endfunction

