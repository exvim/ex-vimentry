au BufRead,BufNewFile *.{exvim,vimentry,vimproject}   set filetype=vimentry
au BufEnter *.{exvim,vimentry,vimproject} call <SID>init_buffer()
au BufWritePost *.{exvim,vimentry,vimproject} call g:ParseVimentry()

function! s:init_buffer()
  " do not show it in buffer list
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
endfunction

" vim:ts=2:sw=2:sts=2
