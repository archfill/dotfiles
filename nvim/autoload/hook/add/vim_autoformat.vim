function! hook#add#vim_autoformat#load() abort
  let g:autoformat_remove_trailing_spaces = 1 " 末尾スペースの除去

  " google_java_formatterの起動コマンド設定
  let g:formatdef_google_java_formatter = '"java -jar ' . g:outher_package_path . '/' . g:google_java_formatter . ' - --aosp"'

  " Javaのフォーマッタの設定
  let g:formatters_java = ['google_java_formatter']

  " 保存時に自動でコードフォーマットされる用に設定
  call s:set_autoformat("java")
endfunction

function! s:set_autoformat(...) abort
  augroup AutoIndentPreWrite
    autocmd!
  augroup End

  for var in a:000
    let l:cmd = 'autocmd AutoIndentPreWrite BufWrite *.' . var . ' :Autoformat'
    execute l:cmd
  endfor
endfunction
