" pasta.vim - Pasting with indentation adjusted to paste destination"
" Author:     Marcin Kulik <http://ku1ik.com/>
" Version:    0.2

if exists("g:loaded_pasta") || &cp || v:version < 700
  finish
endif
let g:loaded_pasta = 1

function! s:NormalPasta(p, o)
  if (getregtype() ==# "V")
    exe "normal! " . a:o . "\<space>\<bs>\<esc>" . v:count1 . '"' . v:register . ']p'
    " Save the `[ and `] marks (point to the last modification)
    let first = getpos("'[")
    let last  = getpos("']")
    normal! k"_dd
    " Compensate the line we have just deleted
    let first[1] -= 1
    let last[1]  -= 1
    call setpos("'[", first)
    call setpos("']", last)
  else
    exe "normal! " . v:count1 . '"' . v:register . a:p
  endif
endfunction

function! s:VisualPasta()
  if (visualmode() ==# "V")
    if (getregtype() ==# "V")
      exe "normal! gv\"_c\<space>\<bs>\<esc>" . v:count1 . '"' . v:register . ']pk"_dd'
    else
      exe "normal! gv\"_c\<space>\<bs>\<esc>" . v:count1 . '"' . v:register . ']p'
    endif
  else
    " workaround strange Vim behavior (""p is no-op in visual mode)
    let reg = v:register == '"' ? '' : '"' . v:register

    exe "normal! gv" . v:count1 . reg . 'pgv"' . v:register . 'y`>'
  endif
endfunction

function! s:SetupPasta()
  if exists("g:pasta_enabled_filetypes")
    if index(g:pasta_enabled_filetypes, &ft) == -1
      return
    endif
  elseif exists("g:pasta_disabled_filetypes") &&
       \ index(g:pasta_disabled_filetypes, &ft) != -1
    return
  endif

  exe "nmap <buffer> " . g:pasta_paste_before_mapping . " <Plug>BeforePasta"
  exe "xmap <buffer> " . g:pasta_paste_before_mapping . " <Plug>VisualPasta"

  exe "nmap <buffer> " . g:pasta_paste_after_mapping . " <Plug>AfterPasta"
  exe "xmap <buffer> " . g:pasta_paste_after_mapping . " <Plug>VisualPasta"
endfunction

if !exists("g:pasta_disabled_filetypes")
  let g:pasta_disabled_filetypes = ["python", "coffee", "markdown",
        \"yaml", "slim", "nerdtree", "netrw", "startify", "ctrlp",
        \"dashboard", "fugitive", "nvimtree"]
endif

if !exists("g:pasta_paste_before_mapping")
  let g:pasta_paste_before_mapping = 'P'
endif

if !exists("g:pasta_paste_after_mapping")
  let g:pasta_paste_after_mapping = 'p'
endif

nnoremap <silent> <Plug>BeforePasta :<C-U>call <SID>NormalPasta('P', 'O')<CR>
nnoremap <silent> <Plug>AfterPasta :<C-U>call <SID>NormalPasta('p', 'o')<CR>
xnoremap <silent> <Plug>VisualPasta :<C-U>call <SID>VisualPasta()<CR>

augroup vim_pasta
  au FileType * call <SID>SetupPasta()
augroup END

" vim:set sw=2 sts=2:
