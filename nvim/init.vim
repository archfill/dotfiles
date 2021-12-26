" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

" ENV
let $CACHE = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let $CONFIG = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME
let $DATA = empty($XDG_DATA_HOME) ? expand('$HOME/.local/share') : $XDG_DATA_HOME

if has('nvim')
  set sh=zsh
  au TermOpen * tnoremap <ESC> <C-\><C-n>
  au FileType fzf tunmap <ESC>
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
else
endif

if has('mac')
  " Mac の共通設定
  let fzfExists=getftype("/opt/homebrew/opt/fzf")
  if fzfExists != ""
    set rtp+=/opt/homebrew/opt/fzf
  else
    set rtp+=/usr/local/opt/fzf
  endif

  let g:memolist_path = expand('$HOME/dotfiles/memolist')
endif

if has('unix')
  set rtp+=~/.fzf
  let g:memolist_path = expand('$HOME/dotfiles/memolist')

  "fcitx ime 制御
  function! ImInActivate()
    call system('fcitx-remote -c')
  endfunction
  inoremap <silent> <C-[> <ESC>:call ImInActivate()<CR>
endif

" Load rc file
function! s:load(file) abort
    let s:path = expand('$CONFIG/nvim/rc/' . a:file . '.vim')

    if filereadable(s:path)
        execute 'source' fnameescape(s:path)
    endif
endfunction

call s:load('plugins')

nnoremap ; :
nnoremap : ;

nnoremap <F3> :noh<CR>

" set clipboard=unnamed,autoselect

syntax enable
set background=dark
"set background=light
colorscheme iceberg
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" font
" set guifont=Cica:h16
set printfont=Cica:h12
"set ambiwidth=single
"set ambiwidth=double


" setting
"文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
set nowritebackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd

set cmdheight=1
set updatetime=300
set shortmess+=c
set signcolumn=yes

set fileencodings=utf-8,sjis,iso-2022-jp,euc-jp
set fileformats=unix,dos,mac


" 見た目系
" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" 現在の行を強調表示（縦）
"set cursorcolumn
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" インデントはスマートインデント
set smartindent
" ビープ音を可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=list:longest
set wildignore+=node_modules/**,.git/**
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
inoremap <silent> jj <ESC>

" Tab系
" 不可視文字を可視化(タブが「▸-」と表示される)
set list listchars=tab:\▸\-
" Tab文字を半角スペースにする
set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2


" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

nnoremap [window] <Nop>
nmap s [window]
nmap <Space> [space]

" autocmd vimenter * NERDTree
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
nnoremap <C-t> :NERDTreeToggle<CR>
"nnoremap <C-s> :NERDTreeFocus<CR>
" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
  exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
  exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction
call NERDTreeHighlightFile('py',     'yellow',  'none', 'yellow',  '#151515')
call NERDTreeHighlightFile('md',     'blue',    'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml',    'yellow',  'none', 'yellow',  '#151515')
call NERDTreeHighlightFile('config', 'yellow',  'none', 'yellow',  '#151515')
call NERDTreeHighlightFile('conf',   'yellow',  'none', 'yellow',  '#151515')
call NERDTreeHighlightFile('json',   'yellow',  'none', 'yellow',  '#151515')
call NERDTreeHighlightFile('html',   'yellow',  'none', 'yellow',  '#151515')
call NERDTreeHighlightFile('styl',   'cyan',    'none', 'cyan',    '#151515')
call NERDTreeHighlightFile('css',    'cyan',    'none', 'cyan',    '#151515')
call NERDTreeHighlightFile('rb',     'red',     'none', 'red',     '#151515')
call NERDTreeHighlightFile('js',     'red',     'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php',    'magenta', 'none', '#ff00ff', '#151515')
call NERDTreeHighlightFile('vue',    'green',   'none', '#4fc08d', '#151515')

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['vue'] = ''
" アイコン入力方法 : `[Ctrl+V]` > `[u]` > `e905`
let g:NERDTreeExtensionHighlightColor = {}
let g:NERDTreeExtensionHighlightColor['vue'] = '42B983'

let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "~",
    \ "Staged"    : "✚",
    \ "Untracked" : "★",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Ignored"   : "☒",
    \ "Unknown"   : "?"
    \ }

if !has('gui_running')
  map "in Insert mode, type Ctrl+v Alt+n here" <A-n>
endif

" neosnippet.vim
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#enable_completed_snippet = 1
let g:neosnippet#expand_word_boundary = 1

" devicon
let g:WebDevIconsUnicodeDecorateFolderNodes = 1

" auto-ctags
let g:auto_ctags = 0
let g:auto_ctags_directory_list = ['.git', '.svn']

" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

"Vista config
nnoremap fv :<C-u>Vista coc<CR>
nnoremap fs :<C-u>Vista finder coc<CR>

"coc config
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" vsession config
" let g:vsession_use_fzf = 1

" tab config
set showtabline=2
" The prefix key.
nnoremap    [Tag]   <Nop>
nmap    t [Tag]
" Tab jump
for n in range(1, 9)
  execute 'nnoremap <silent> [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor
" t1 で1番左のタブ、t2 で1番左から2番目のタブにジャンプ

noremap <silent> [Tag]c :tablast <bar> tabnew<CR>
" tc 新しいタブを一番右に作る
noremap <silent> [Tag]x :tabclose<CR>
" tx タブを閉じる
noremap <silent> [Tag]n :tabnext<CR>
" tn 次のタブ
noremap <silent> [Tag]p :tabprevious<CR>
" tp 前のタブ

" fzf config
nnoremap <silent> ,f :GFiles<CR>
nnoremap <silent> ,F :GFiles?<CR>
nnoremap <silent> ,b :Buffers<CR>
nnoremap <silent> ,l :BLines<CR>
nnoremap <silent> ,h :History<CR>
nnoremap <silent> ,m :Mark<CR>

" ghq config
function! s:cd_repo(shell, repo) abort
  exe 'lcd' trim(system('ghq root')) .. '/' .. a:repo
  pwd
endfunction

function! s:repo(multi, cb) abort
  if executable('ghq') && exists('*fzf#run()') && executable('fzf')
    call fzf#run({
          \ 'source': systemlist('ghq list'),
          \ 'sink': a:cb,
          \ 'options': a:multi,
          \ 'down': '40%'},
          \ )
  else
    echo "doesn't installed ghq or fzf.vim(require fzf)"
  endif
endfunction

command! Repo call s:repo('+m', function('s:cd_repo', [&shell]))

" vim-fugitive config
nnoremap <leader>gs :tab sp<CR>:Git<CR>:only<CR>
nnoremap <leader>ga :Gwrite<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gl :Git log<CR>
nnoremap <leader>gh :tab sp<CR>:0Glog<CR>
" abbrev for `git history`: create new quickfix tab for history
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gf :Gfetch<CR>
nnoremap <leader>gd :Gvdiff<CR>
nnoremap <leader>gr :Grebase -i<CR>
nnoremap <leader>gg :Ggrep 
nnoremap <leader>gm :Gmerge

" autohighlight vue file
autocmd FileType vue syntax sync fromstart

command! -nargs=0 Fq call fzf#run({
\ 'source': 'ghq list --full-path',
\ 'sink': 'cd'
\ })

set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
hi NonText    ctermbg=None ctermfg=None guibg=NONE guifg=#8f8f8f
hi SpecialKey ctermbg=None ctermfg=None guibg=NONE guifg=#8f8f8f

"全角スペースをハイライト表示
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif

"透明化
"highlight Normal ctermbg=none
"highlight NonText ctermbg=none
"highlight LineNr ctermbg=none
"highlight Folded ctermbg=none
"highlight EndOfBuffer ctermbg=none

"vim debug
let g:vimspector_enable_mappings = 'HUMAN'

" NERDCommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

set tags+=.git/tags

" skkeleton
imap <C-j> <Plug>(skkeleton-toggle)
cmap <C-j> <Plug>(skkeleton-toggle)

call skkeleton#config({
  \ 'useSkkServer': v:true,
  \ 'eggLikeNewline': v:true,
  \ })

