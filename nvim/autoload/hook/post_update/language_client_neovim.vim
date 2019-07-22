function! hook#post_update#language_client_neovim#load() abort
  " !./install.sh
  " g:outher_package_pathは、`eclipse.jdt.ls`などの外部ツールのインストール先ディレクトリ。
  " 省略しているが、`init.vim`で設定している。
  let l:jdt_lsp_path = expand(g:outher_package_path) . "/jdt-lsp"
  let l:jdt_lsp_version = expand('0.42.0-201907181837')
  " 指定のディレクトリに`eclipse.jdt.ls`が存在するか確認
  if !executable(l:jdt_lsp_path . "/plugins/" . expand(g:ldt_lsp_jar_name) . ".jar")
    " `eclipse.jdt.ls`のダウンロード
    execute "!curl -o /tmp/tmp_jdt_lsp.tar.gz http://download.eclipse.org/jdtls/snapshots/jdt-language-server-" . expand(l:jdt_lsp_version) . ".tar.gz"
    " `eclipse.jdt.ls`の保存先ディレクトリを作成
    call mkdir(l:jdt_lsp_path, "p")
    " ダウンロードしてきたファイルを保存先ディレクトリに解凍
    execute "!tar xf /tmp/tmp_jdt_lsp.tar.gz -C " . l:jdt_lsp_path
    " tar.gzファイルを削除
    !rm /tmp/tmp_jdt_lsp.tar.gz
  endif
endfunction
