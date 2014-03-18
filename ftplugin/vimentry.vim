" NOTE: ftplugin script only execute one time when you open the file

let s:varnames = []
let s:filename = expand('%')
let s:version = 26

function! s:write_default_template() 
  " NOTE: we use the dir path of .vimentry instead of getcwd().  
  let cwd = ex#path#translate( fnamemodify( s:filename, ':p:h' ), 'unix' )
  let projectName = fnamemodify( s:filename, ":t:r" )  
  let folderName = '.exvim.'.projectName

  " the parameter will parse as let g:ex_{var} = val
  call append ( 0, [
        \ "-- Edit and save the file.",
        \ "-- The variables will be loaded and exists as g:ex_{var} in Vim's runtime.",
        \ "-- For example, \"foo = true\" will be \"g:ex_foo\", and the value is \"true\"",
        \ "",
        \ "-- Choose your project type",
        \ "-- Press <F5> to apply project_type for other settings",
        \ "project_type = auto -- { auto, clang, web, js, python, lua, ruby }",
        \ "",
        \ "-- Project Settings:",
        \ "cwd = " . cwd,
        \ "version = " . s:version,
        \ "project_name = " . projectName,
        \ "project_folder = " . folderName,
        \ "",
        \ "-- ex_project Options:",
        \ "enable_project_browser = true -- { true, false }",
        \ "project_browser = ex -- { ex, nerdtree }",
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
        \ "-- sub projects:",
        \ "-- sub_project_refs += foobar1.exvim -- example",
        \ "-- sub_project_refs += foobar2.exvim -- example",
        \ ] )

  silent exec "w!"
  silent exec "normal gg"

  call s:parse_vimentry()
endfunction

function! s:parse_vimentry() 
  " remove old global variables 
  for varname in s:varnames
    exec "unlet " . varname
  endfor
  let s:varnames = [] " list clean 

  " parse each line to get variable
  for line in getline(1,'$')
    let pos = match(line,'+=\|=')
    if pos == -1 " if the line is comment line, skip it.
      continue 
    endif

    let var = matchstr( line, '^\w\+\(\s*\(+=\|=\)\)\@=', 0 )
    let val = matchstr( line, '\(\(+=\|=\)\s*\)\@<=\S\+', pos )

    " DEBUG: echomsg var . "=" . val

    if var != "" && val != "" 
      if stridx ( line, '+=') == -1
        let g:ex_{var} = val
      else " create list variables
        let exprList = split(line, "+=")
        if len(exprList)>=2 " we can define a variable if the number of split list itmes more than one
          if !exists( 'g:ex_'.var ) " if we don't define this list variable, define it first
            let g:ex_{var} = []
          endif
          " now add items to the list
          call add ( g:ex_{var}, val )
        endif
      endif

      call add( s:varnames, 'g:ex_'.var )
    endif
  endfor

  " DEBUG:
  " for varname in s:varnames
  "   echomsg varname
  " endfor
endfunction

" if the file is empty, we creat a template for it
if findfile( fnamemodify(s:filename,':p'), '.;' ) == "" || empty( readfile(s:filename) )
  call <SID>write_default_template()
else
  call <SID>parse_vimentry()
endif

" key mappings
nnoremap <silent> <buffer> <F5> :call <SID>parse_vimentry()<CR>
let g:ParseVimentry = function('<SID>parse_vimentry') 

" vim:ts=2:sw=2:sts=2
