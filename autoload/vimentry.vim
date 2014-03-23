" variables {{{1
let s:varnames = []
let g:ex_vimentry_version = 3
" }}}

" functions {{{1

" vimentry#write_default_template {{{2
function vimentry#write_default_template() 
    " clear screen
    silent 1,$d _

    " NOTE: we use the dir path of .vimentry instead of getcwd().  
    let filename = expand('%')
    let cwd = ex#path#translate( fnamemodify( filename, ':p:h' ), 'unix' )
    let projectName = fnamemodify( filename, ":t:r" )  

    " the parameter will parse as let g:ex_{var} = val
    silent call append ( 0, [
                \ "-- Edit and save the file.",
                \ "-- The variables will be loaded and exists as g:ex_{var} in Vim's runtime.",
                \ "-- For example, \"foo = true\" will be \"g:ex_foo\", and the value is \"true\"",
                \ "",
                \ "-- Choose your project type",
                \ "-- Press <F5> to apply project_type for other settings",
                \ "project_type = all -- { all, build, clang, data, doc, game, server, shell, web, ... }",
                \ "",
                \ "-- Project Settings:",
                \ "cwd = " . cwd,
                \ "version = " . g:ex_vimentry_version,
                \ "project_name = " . projectName,
                \ "",
                \ "-- ex_project Options:",
                \ "enable_project_browser = true -- { true, false }",
                \ "project_browser = ex -- { ex, nerdtree }",
                \ "folder_filter_mode = include -- { include, exclude }",
                \ "folder_filter += ",
                \ "file_filter += ",
                \ "file_ignore_pattern += ",
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

" vimentry#parse {{{2
function vimentry#parse() 
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
            if !exists( 'g:ex_'.var )
                silent call add( s:varnames, 'g:ex_'.var )
            endif

            " list variable 
            " sytanx: 
            " list = val1,val2,
            " list += val1
            " list += val1,val2
            if stridx ( line, '+=') != -1 || stridx ( val, ',' ) != -1
                if !exists( 'g:ex_'.var ) " if we don't define this list variable, define it first
                    let g:ex_{var} = []
                endif


                let vallist = split( val, ',' )
                for v in vallist
                    if v != ""
                        silent call add ( g:ex_{var}, v )
                    endif
                endfor

            " string variable
            else
                let g:ex_{var} = val
            endif
        endif
    endfor

    " DEBUG:
    " for varname in s:varnames
    "     echomsg varname . " = " . string({varname}) 
    " endfor
endfunction

" vimentry#on {{{2
let s:event_listeners = {
            \ 'reset': [],
            \ 'changed': [],
            \ 'project_type_changed': [],
            \ } 

function vimentry#on( event, funcref ) 
    if !has_key( s:event_listeners, a:event )
        call ex#warning( "Cant find event " . a:event )
        return
    endif

    if type(a:funcref) != 2
        call ex#warning( "the second argument must be a function ref" )
    endif

    silent call add ( s:event_listeners[a:event], a:funcref )
endfunction

" vimentry#apply_project_type {{{2
function vimentry#apply_project_type() 
    " invoke project_type_changed event
    " NOTE: function ref variable must start with captial character
    let listeners = s:event_listeners['project_type_changed']
    for Funcref in listeners
        call Funcref()
    endfor
endfunction

" vimentry#reset {{{2
function vimentry#reset() 
    " invoke reset event
    " NOTE: function ref variable must start with captial character
    let listeners = s:event_listeners['reset']
    for Funcref in listeners
        call Funcref()
    endfor
endfunction

" vimentry#apply {{{2
function vimentry#apply() 
    " pre-check 
    if !exists( 'g:ex_cwd' )
        call ex#error("Can't find vimentry setting 'cwd'")
        return
    endif

    if !exists('g:ex_project_name')
        call ex#error("Can't find vimentry setting 'project_name'")
        return
    endif

    " set parent working directory
    silent exec 'cd ' . escape(g:ex_cwd, " ")

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

    " invoke changed event
    " NOTE: function ref variable must start with captial character
    let listeners = s:event_listeners['changed']
    for Funcref in listeners
        call Funcref()
    endfor
endfunction

"}}}1

" vim:ts=4:sw=4:sts=4 et fdm=marker:
