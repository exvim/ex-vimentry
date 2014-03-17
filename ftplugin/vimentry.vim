" NOTE: ftplugin script only execute one time when you open the file

let s:filename = expand('%')
let s:version = 26

function! s:write_default_template() 
  " NOTE: we use the dir path of .vimentry instead of getcwd().  
  let cwd = ex#path#translate( fnamemodify( s:filename, ':p:h' ), 'unix' )
  let vimentryName = fnamemodify( s:filename, ":t:r" )  
  let folderName = '.vimfiles.'.vimentryName

  call append ( 0, [
        \ "cwd = " . cwd,
        \ "version = " . s:version,
        \ "projectName = " . vimentryName,
        \ "projectFolder = " . folderName,
        \ ] )

endfunction

" if the file is empty, we creat a template for it
if findfile( fnamemodify(s:filename,':p'), '.;' ) == "" || empty( readfile(s:filename) )
  call <SID>write_default_template()
endif

" vim:ts=2:sw=2:sts=2
