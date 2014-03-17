au BufRead,BufNewFile *.{vimentry,vimproject,exvim}   set filetype=vimentry
au BufEnter *.{vimentry,vimproject,exvim} call <SID>init_buffer()

function! s:init_buffer()
  " do not show it in buffer list
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
endfunction

" vim:ts=2:sw=2:sts=2
