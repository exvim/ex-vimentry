" NOTE: ftplugin script only execute one time when you open the file

" static variables {{{1
let s:varnames = []
let s:filename = expand('%')
let s:version = 1
"}}}
" functions {{{1
" s:write_default_template {{{2
function! s:write_default_template() 
    " clear screen
    silent 1,$d _

    " NOTE: we use the dir path of .vimentry instead of getcwd().  
    let cwd = ex#path#translate( fnamemodify( s:filename, ':p:h' ), 'unix' )
    let projectName = fnamemodify( s:filename, ":t:r" )  

    " the parameter will parse as let g:ex_{var} = val
    silent call append ( 0, [
                \ "-- Edit and save the file.",
                \ "-- The variables will be loaded and exists as g:ex_{var} in Vim's runtime.",
                \ "-- For example, \"foo = true\" will be \"g:ex_foo\", and the value is \"true\"",
                \ "",
                \ "-- Choose your project type",
                \ "-- Press <F5> to apply project_type for other settings",
                \ "project_type = all -- { all, clang, web, js, shader, python, lua, ruby, ... }",
                \ "file_filter = ",
                \ "folders_included = ",
                \ "folders_excluded = ",
                \ "",
                \ "-- Project Settings:",
                \ "cwd = " . cwd,
                \ "version = " . s:version,
                \ "project_name = " . projectName,
                \ "",
                \ "-- ex_project Options:",
                \ "enable_project_browser = true -- { true, false }",
                \ "project_browser = nerdtree -- { ex, nerdtree }",
                \ "",
                \ "-- ex_gsearch Options:",
                \ "enable_gsearch = true -- { true, false }",
                \ "gsearch_engine = idutils -- { idutils, grep }",
                \ "",
                \ "-- ex_tags Options:",
                \ "enable_tags = true -- { true, false }",
                \ "enable_symbols = true -- { true, false }",
                \ "enable_inherits = true -- { true, false }",
                \ "",
                \ "-- ex_cscope Options:",
                \ "enable_cscope = true -- { true, false }",
                \ "",
                \ "-- ex_macrohl Options:",
                \ "enable_macrohl = true -- { true, false }",
                \ "",
                \ "-- sub projects:",
                \ "-- sub_project_refs += foobar1.exvim -- example",
                \ "-- sub_project_refs += foobar2.exvim -- example",
                \ ] )

    " NOTE: this will not invoke 'au BufWritePost' in ftdetect/vimentry.vim
    silent exec "w!"
    silent exec "normal gg"
endfunction

" s:parse_vimentry {{{2
function! s:parse_vimentry() 
    " remove old global variables 
    for varname in s:varnames
        unlet {varname}
    endfor
    let s:varnames = [] " list clean 

    " parse each line to get variable
    for line in getline(1,'$')
        let pos = match(line,'^\w\+\s*\(+=\|=\)\s*\S*')
        if pos == -1 " if the line is comment line, skip it.
            continue 
        endif

        let var = matchstr( line, '^\w\+\(\s*\(+=\|=\)\)\@=', 0 )
        let val = matchstr( line, '\(\(+=\|=\)\s*\)\@<=\S\+', pos )

        " DEBUG:
        " echomsg var . "=" . val

        if var != ""
            if stridx ( line, '+=') == -1 " string variable
                let g:ex_{var} = val
            else " list variable
                if !exists( 'g:ex_'.var ) " if we don't define this list variable, define it first
                    let g:ex_{var} = []
                endif

                if val != ""
                    " now add items to the list
                    silent call add ( g:ex_{var}, val )
                endif
            endif

            silent call add( s:varnames, 'g:ex_'.var )
        endif
    endfor

    " DEBUG:
    " for varname in s:varnames
    "   echomsg varname . " = " . {varname} 
    " endfor
endfunction

" s:apply_project_type {{{2
function! s:apply_project_type() 
    " TODO:
endfunction

" s:apply_vimentry {{{2
function! s:apply_vimentry() 
    " set parent working directory
    if exists( 'g:ex_cwd' )
        silent exec 'cd ' . escape(g:ex_cwd, " ")
    else
        call ex#error("Can't find vimentry setting 'cwd'")
        return
    endif

    " set title
    if exists('g:ex_project_name')
        au VimEnter,BufNewFile,BufEnter * let &titlestring = g:ex_project_name . ' : %t %M%r (' . expand("%:p:h") . ')' . ' %h%w%y'
    else
        call ex#error("Can't find vimentry setting 'project_name'")
        return
    endif

    " save the .exvim.xxx/ fullpath to g:exvim_files_path 
    let g:exvim_files_path = g:ex_cwd.'/.exvim.'.g:ex_project_name

    " create folder .exvim.xxx/ if not exists
    let path = g:exvim_files_path
    if finddir(path) == ''
        silent call mkdir(path)
    endif

    " create folder .exvim.xxx/tmp/ if not exists
    let path = g:exvim_files_path.'/tmp' 
    if finddir(path) == ''
        silent call mkdir(path)
    endif

    " apply project_type settings
    if exists('g:ex_project_type')
        " TODO:
        " let lang_list = split( g:exES_LangType, ',' )
        " silent call exUtility#SetProjectFilter ( "file_filter", exUtility#GetFileFilterByLanguage (lang_list) )
    endif

    " call exUtility#CreateIDLangMap ( exUtility#GetProjectFilter("file_filter") )
    " call exUtility#CreateQuickGenProject ()

    " set tag file path
    if exists( 'g:ex_enable_tags' ) && g:ex_enable_tags == "true"
        " let &tags = &tags . ',' . g:exES_Tag
        let &tags = escape(g:exvim_files_path."/tags", " ")
    endif

    " create .exvim.xxx/hierarchies/
    if exists( 'g:ex_enable_inherits' ) && g:ex_enable_inherits == "true"
        " TODO:
        " let inherit_directory_path = g:exES_CWD.'/'.g:exES_vimfiles_dirname.'/.hierarchies' 
        " if finddir(inherit_directory_path) == ''
        "   silent call mkdir(inherit_directory_path)
        " endif
    endif

    " set cscope file path
    if exists( 'g:ex_enable_cscope' ) && g:ex_enable_cscope == "true"
        " TODO: silent call g:exCS_ConnectCscopeFile()
    endif

    " macro highlight
    if exists( 'g:ex_enable_macrohl' ) && g:ex_enable_macrohl == "true" 
        " TODO: silent call g:exMH_InitMacroList(g:exES_Macro)
    endif

    " TODO:
    " " set vimentry references
    " if exists ('g:exES_vimentryRefs')
    "   for vimentry in g:exES_vimentryRefs
    "     let ref_entry_dir = fnamemodify( vimentry, ':p:h')
    "     let ref_vimfiles_dirname = '.vimfiles.' . fnamemodify( vimentry, ":t:r" )
    "     let fullpath_tagfile = exUtility#GetVimFile ( ref_entry_dir, ref_vimfiles_dirname, 'tag')
    "     if has ('win32')
    "       let fullpath_tagfile = exUtility#Pathfmt( fullpath_tagfile, 'windows' )
    "     elseif has ('unix')
    "       let fullpath_tagfile = exUtility#Pathfmt( fullpath_tagfile, 'unix' )
    "     endif
    "     if findfile ( fullpath_tagfile ) != ''
    "       let &tags .= ',' . fullpath_tagfile
    "     endif
    "   endfor
    " endif

    " run custom scripts
    if exists('*g:exvim_post_init')
        call g:exvim_post_init()
    endif
endfunction

" s:apply_vimentry_after_bufenter {{{2
" NOTE: we can't apply window open behavior during BufRead, because the
" syntax/ file was not load it yet, and if we open to another a window it 
" will start a new buffer and apply the syntax/ settings on the new buffer
function! s:apply_vimentry_after_bufenter() 
    " open project window
    if exists( 'g:ex_enable_project_browser' ) && g:ex_enable_project_browser == "true"
        if exists( 'g:ex_project_browser' )
            if g:ex_project_browser == "ex"
                " TODO: silent exec g:exES_project_cmd.' '.g:exES_Project
            elseif g:ex_project_browser == "nerdtree"
                silent exec 'NERDTree'
            endif
        end
    endif
endfunction

" s:init_buffer {{{2
function! s:init_buffer()
    " do not show it in buffer list
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nowrap

    if b:bufenter_apply == 1
        let b:bufenter_apply = 0
        call s:apply_vimentry_after_bufenter()
    endif
endfunction

" s:init_vimentry {{{2
function! s:init_vimentry( reload ) 
    " if the file is empty, we creat a template for it
    if findfile( fnamemodify(s:filename,':p'), '.;' ) == "" || empty( readfile(s:filename) )
        call s:write_default_template()
    endif
    call s:parse_vimentry()

    let b:bufenter_apply = 0
    if !exists('g:ex_version') 
        call ex#error('Invalid vimentry file')
        return
    endif

    " if the version is different, write the vimentry file with template and re-parse it  
    if g:ex_version != s:version
        call s:write_default_template()
        call s:parse_vimentry()
    endif

    " apply vimentry settings
    call s:apply_vimentry()
    if a:reload == 1
        call s:apply_vimentry_after_bufenter()
    else
        let b:bufenter_apply = 1
    endif
endfunction
"}}}1
" public {{{1
" autocmd
au! BufEnter <buffer> call <SID>init_buffer()
au! BufWritePost <buffer> call <SID>init_vimentry(1)

" key mappings
nnoremap <silent> <buffer> <F5> :call <SID>apply_project_type()<CR>

" do init
call s:init_vimentry(0)
"}}}

" vim:ts=4:sw=4:sts=4 et fdm=marker:
