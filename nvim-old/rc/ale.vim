" 保存時のみ実行する
let g:ale_lint_on_text_changed = 0
" 表示に関する設定
let g:ale_sign_error      = '✖ ' " エラーシンボル
let g:ale_sign_warning    = '⚠ ' " 警告シンボル
let g:airline#extensions#ale#open_lnum_symbol = '('
let g:airline#extensions#ale#close_lnum_symbol = ')'
let g:ale_echo_msg_format = '[%linter%]%code: %%s'
highlight link ALEErrorSign Tag
highlight link ALEWarningSign StorageClass

"let b:ale_linters = {
"\   'javascript': ['eslint', 'eslint-plugin-vue'],
"\   'python': ['pyflakes', 'pep8'],
"\   'ruby': ['rubocop'],
"\   'tex': ['textlint'],
"\   'markdown': ['textlint'],
"\   'css': ['stylelint'],
"\}
let g:ale_statusline_format = ['E%d', 'W%d', 'ok']
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

" Ctrl + kで次の指摘へ、Ctrl + jで前の指摘へ移動
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
