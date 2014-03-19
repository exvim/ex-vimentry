" NOTE: ftplugin script only execute one time when you open the file

" functions {{{1

" s:init_buffer {{{2
function! s:init_buffer()
    " do not show it in buffer list
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nowrap

    if b:bufenter_apply == 1
        let b:bufenter_apply = 0
        call vimentry#apply_after_bufenter()
    endif
endfunction

" s:init_vimentry {{{2
function! s:init_vimentry( reload ) 
    let filename = expand('%')

    " if the file is empty, we creat a template for it
    if findfile( fnamemodify(filename,':p'), '.;' ) == "" || empty( readfile(filename) )
        call vimentry#write_default_template()
    endif
    call vimentry#parse()

    " reset last applys
    call vimentry#reset()

    "
    if !exists('g:ex_version') 
        call ex#error('Invalid vimentry file')
        return
    endif

    " if the version is different, write the vimentry file with template and re-parse it  
    if g:ex_version != g:ex_vimentry_version
        call vimentry#write_default_template()
        call vimentry#parse()
    endif

    " apply vimentry settings
    call vimentry#apply()
    if a:reload == 1
        call vimentry#apply_after_bufenter()
    else
        let b:bufenter_apply = 1
    endif
endfunction
"}}}1

" autocmd {{{1
au! BufEnter <buffer> call <SID>init_buffer()
au! BufWritePost <buffer> call <SID>init_vimentry(1)
"}}}1

" key mappings {{{1
nnoremap <silent> <buffer> <F5> :call <SID>apply_project_type()<CR>
"}}}1

" do init
call s:init_vimentry(0)

" vim:ts=4:sw=4:sts=4 et fdm=marker:
