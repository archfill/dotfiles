let g:lightline = {
\ 'colorscheme': 'iceberg',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'fugitive', 'filename' ],
\             [ 'coc' ],
\           ],
\ },
\ 'component_function': {
\   'fugitive': 'LightLineFugitive',
\   'readonly': 'LightLineReadonly',
\   'modified': 'LightLineModified',
\   'filename': 'LightLineFilename',
\   'filetype': 'LightLineFiletype',
\   'fileformat': 'LightLineFileformat',
\   'coc': 'coc#status',
\ },
\ 'separator': { 'left': "\ue0b4", 'right': "\ue0b6" },
\ 'subseparator': { 'left': "\ue0b5", 'right': "\ue0b7" },
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

