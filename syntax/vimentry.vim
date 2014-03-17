" syntax highlight
syn match vimentrySetting transparent  "^.\{-}=.*$" contains=vimentryVar,vimentryOperator
syn match vimentryVar	"^.\{-}=" contained contains=vimentryOperator
syn match vimentryVal	"[^+=].*$" contained " contains=vimentryDeref
syn match vimentryOperator	"+*=.*$" contained contains=vimentryVal
syn match vimentryComment	"^-- .\+$" 
" KEEPME: syn region vimentryDeref start="\${" end="}" contained

hi default link vimentryVar vimVar
hi default link vimentryVal vimCommand
hi default link vimentryOperator Operator
hi default link vimentryComment Comment

" vim:ts=2:sw=2:sts=2
