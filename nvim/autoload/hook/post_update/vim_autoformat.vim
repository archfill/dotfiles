function! hook#post_update#vim_autoformat#load() abort
  " `google_java_formatter`がインストールさてれているか確認
  let l:google_java_formatter = expand(g:outher_package_path) . "/" . expand(g:google_java_formatter_jar_name) . "-all-deps.jar"
  if !executable(l:google_java_formatter)
    " 未インストールの場合はjarをダウンロード
     execute "!wget https://github.com/google/google-java-format/releases/download/" . expand(g:google_java_formatter_jar_name) . "/" . expand(g:google_java_formatter_jar_name) . "-all-deps.jar -P " . expand(g:outher_package_path)
  endif
endfunction
