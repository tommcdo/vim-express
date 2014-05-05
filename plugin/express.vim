function! s:express(type, ...)
	let expression = input('=', '', 'expression')
	if expression =~? '^\([gswbv]:\)\?[a-z][a-z0-9#:_]\+$'
		let expression = expression.'(v:val)'
	endif
	call s:set(map([s:get(a:type, a:0)], expression)[0])
	call s:repeat(expression)
endfunction

function! s:subpress(type, ...)
	let input = input(':s', '/')
	let args = split(input, '\\\@<!'.input[0])
	if len(args) == 2
		let args = args + ['']
	endif
	let lines = split(s:get(a:type, a:0), "\n")
	call s:set(join(map(lines, 'call("substitute", [v:val] + args)'), "\n"))
	call s:repeat("\<BS>".input)
endfunction

function! s:get(type, vis)
	let a_reg = @a
	let selection = &selection

	set selection=inclusive
	let selectcmd = "`[v`]"
	if a:vis
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
	let value = @a
	let &selection = selection

	let @a = a_reg
	return value
endfunction

function! s:set(value)
	let a_reg = @a
	let selection = &selection

	set selection=inclusive
	let @a = a:value
	execute 'normal! gv"ap'

	let &selection = selection
	let @a = a_reg
endfunction

function! s:repeat(input)
	silent! call repeat#set("\<Plug>(ExpressRepeat)".a:input."\<CR>")
endfunction

function! s:create_map(mode, lhs, rhs)
	if !hasmapto(a:rhs, a:mode)
		execute a:mode.'map' a:lhs a:rhs
	endif
endfunction

nnoremap <silent> <Plug>(ExpressRepeat) .

nnoremap <silent> <Plug>(Express) :<C-U>set operatorfunc=<SID>express<CR>g@
nnoremap <silent> <Plug>(ExpressLine) :<C-U>set operatorfunc=<SID>express<CR>g@_
vnoremap <silent> <Plug>(Express) :<C-U>call <SID>express(visualmode(), 1)<CR>

nnoremap <silent> <Plug>(Subpress) :<C-U>set operatorfunc=<SID>subpress<CR>g@
nnoremap <silent> <Plug>(SubpressLine) :<C-U>set operatorfunc=<SID>subpress<CR>g@_
vnoremap <silent> <Plug>(Subpress) :<C-U>call <SID>subpress(visualmode(), 1)<CR>

if exists('g:express_no_mappings')
	finish
endif

call s:create_map('n', 'g=', '<Plug>(Express)')
call s:create_map('n', 'g==', '<Plug>(ExpressLine)')
call s:create_map('v', 'g=', '<Plug>(Express)')

call s:create_map('n', 'g:', '<Plug>(Subpress)')
call s:create_map('n', 'g::', '<Plug>(SubpressLine)')
call s:create_map('v', 'g:', '<Plug>(Subpress)')
