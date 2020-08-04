let g:lightline = {
\ 'colorscheme': 'iceberg',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'fugitive', 'filename' ],
\             [ 'vista' ],
\             [ 'coc' ]
\           ],
\ },
\ 'component_function': {
\   'fugitive': 'LightLineFugitive',
\   'readonly': 'LightLineReadonly',
\   'modified': 'LightLineModified',
\   'filename': 'LightLineFilename',
\   'filetype': 'LightLineFiletype',
\   'fileformat': 'LightLineFileformat',
\   'vista': 'NearestMethodOrFunction',
\   'coc': 'coc#status',
\ },
\ 'separator': { 'left': "\ue0b0 ", 'right': "\ue0b2 " },
\ 'subseparator': { 'left': "\ue0b1 ", 'right': "\ue0b3 " }
\ }

function! LightLineModified()
    if &filetype == "help"
        return ""
    elseif &modified
        return "+"
    elseif &modifiable
        return ""
    else
        return ""
    endif
endfunction

function! LightLineReadonly()
    if &filetype == "help"
        return ""
    elseif &readonly
        return " "
    else
        return ""
    endif
endfunction

function! LightLineFugitive()
    if exists("*fugitive#head")
        let _ = fugitive#head()
        return strlen(_) ? ' '._ : ''
    endif
    return ''
endfunction

function! LightLineFilename()
    return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
                \ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
                \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
