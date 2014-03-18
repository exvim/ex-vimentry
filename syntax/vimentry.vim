" syntax highlight
syn match vimentrySetting transparent "^\w\+\s*\(+=\|=\)\s*\S*" contains=vimentryVar,vimentryVal,vimentryOperator
syn match vimentryOperator	"\(+=\|=\)" contained
syn match vimentryVar	"^\w\+\(\s*\(+=\|=\)\)\@=" contained
syn match vimentryVal	"\(\(+=\|=\)\s*\)\@<=\S\+" contained
syn region vimentryComment start="--" skip="\\$" end="$" keepend
syn match vimentryError "\S\+" contains=vimentrySetting,vimentryComment

hi default link vimentryVar vimVar
hi default link vimentryVal vimCommand
hi default link vimentryOperator Operator
hi default link vimentryComment Comment
hi default link vimentryError ErrorMsg

" vim:ts=2:sw=2:sts=2
