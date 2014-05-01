function! s:express(type, ...)
	let expression = input('=', '', 'expression')
	let a_reg = @a
	let selection = &selection
	set selection=inclusive
	let selectcmd = "`[v`]"
	if a:0
		if a:type ==# 'v'
			let selectcmd = "`<v`>"
		elseif a:type ==# 'V'
			let selectcmd = "'<V'>"
		endif
	else
		if a:type == 'line'
			let selectcmd = "'[V']"
		endif
	endif
	execute 'normal!'.selectcmd.'"ay'
	let @a = map([@a], expression)[0]
	execute 'normal! '.selectcmd.'"ap'
	silent! call repeat#set("\<Plug>(ExpressRepeat)".expression."\<CR>")
	let &selection = selection
	let @a = a_reg
endfunction

nnoremap <silent> <Plug>(ExpressRepeat) .
nnoremap <silent> <Plug>(Express) :<C-U>set operatorfunc=<SID>express<CR>g@
nnoremap <silent> <Plug>(ExpressLine) :<C-U>set operatorfunc=<SID>express<CR>g@_
vnoremap <silent> <Plug>(Express) :<C-U>call <SID>express(visualmode(), 1)<CR>
nmap g= <Plug>(Express)
nmap g== <Plug>(ExpressLine)
vmap g= <Plug>(Express)
