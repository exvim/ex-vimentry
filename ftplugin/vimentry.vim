" NOTE: ftplugin script only execute one time when you open the file

"/////////////////////////////////////////////////////////////////////////////
" variables
"/////////////////////////////////////////////////////////////////////////////

let s:varnames = []
let s:filename = expand('%')
let s:version = 26

"/////////////////////////////////////////////////////////////////////////////
" functions
"/////////////////////////////////////////////////////////////////////////////

function! s:write_default_template() 
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

      " string variable
      if stridx ( line, '+=') == -1
        let g:ex_{var} = val

      " list variable
      else
        let exprList = split(line, "+=")
        if len(exprList)>=2 " we can define a variable if the number of split list itmes more than one
          if !exists( 'g:ex_'.var ) " if we don't define this list variable, define it first
            let g:ex_{var} = []
          endif

          if val != ""
            " now add items to the list
            silent call add ( g:ex_{var}, val )
          endif
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

function! s:apply_project_type() 
  " TODO:
endfunction

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

  " open project window
  if exists( 'g:ex_enable_project_browser' ) && g:ex_enable_project_browser == "true"
    " if exists( 'g:ex_project_browser' )
    "   if g:ex_project_browser == "ex"
    "     " TODO: silent exec g:exES_project_cmd.' '.g:exES_Project
    "   elseif g:ex_project_browser == "nerdtree"
    "     silent exec 'NERDTree'
    "   endif
    " end
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

"/////////////////////////////////////////////////////////////////////////////
" public
"/////////////////////////////////////////////////////////////////////////////

function! g:ex_init_vimentry() 
  " if the file is empty, we creat a template for it
  if findfile( fnamemodify(s:filename,':p'), '.;' ) == "" || empty( readfile(s:filename) )
    call <SID>write_default_template()
  endif
  call <SID>parse_vimentry()

  " if the version is different, write the vimentry file with template and re-parse it  
  if g:ex_version != s:version
    call <SID>write_default_template()
    call <SID>parse_vimentry()
  endif

  " apply vimentry settings
  call <SID>apply_vimentry()
endfunction

" key mappings
nnoremap <silent> <buffer> <F5> :call <SID>apply_project_type()<CR>
call g:ex_init_vimentry()

" vim:ts=2:sw=2:sts=2
