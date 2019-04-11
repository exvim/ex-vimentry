let g:ex_vim_entered = 0

function! s:on_vim_enter()
    let g:ex_vim_entered = 1
endfunction

if !exists(g:ex_project_browser)
    let g:ex_project_browser = 'nerdtree' "nerdtree ex
endif

if !exists(g:ex_gsearch_engine)
    let g:ex_gsearch_engine = 'ag' "idutils ag grep
endif

if !exists(g:ex_cscope_engine)
    let g:ex_cscope_engine = 'gtags' "gtags cscope
endif

" autocmd {{{
augroup ex_vimentry
    au!
    au VimEnter * call <SID>on_vim_enter()
augroup END
" }}}

" vim:ts=4:sw=4:sts=4 et fdm=marker:
