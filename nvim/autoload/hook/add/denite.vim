function! hook#add#denite#load() abort
  nmap <silent> <C-u><C-t> :<C-u>Denite filetype<CR>
  nmap <silent> <C-u><C-p> :<C-u>Denite file/rec<CR>
  nmap <silent> <C-u><C-j> :<C-u>Denite line<CR>
  nmap <silent> <C-u><C-g> :<C-u>Denite grep<CR>
  nmap <silent> <C-u><C-]> :<C-u>DeniteCursorWord grep<CR>
  nmap <silent> <C-u><C-u> :<C-u>Denite file/mru<CR>
  nmap <silent> <C-u><C-y> :<C-u>Denite neoyank<CR>
  nmap <silent> <C-u><C-r> :<C-u>Denite -resume<CR>
  nmap <silent> <C-u>; :<C-u>Denite -resume -immediately -select=+1<CR>
  nmap <silent> <C-u>- :<C-u>Denite -resume -immediately -select=-1<CR>
  nmap <silent> <C-u><C-d> :<C-u>call denite#start([{'name': 'file/rec', 'args': ['~/dotfiles']}])<CR>
  nnoremap ml :<C-u>call denite#start([{'name': 'file/rec', 'args': [g:memolist_path]}])<CR>
endfunction

