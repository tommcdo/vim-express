function! s:express(type, ...)
	let expression = input('=', '', 'expression')
	if expression == ''
		return
	endif
	if expression =~? '^\([gswbv]:\)\?[a-z][a-z0-9#:_]\+$'
		let expression = expression.'(v:val)'
	elseif expression =~? '^!'
		let expression = 'system("'.escape(expression[1:], '"\').'", v:val)'
	endif
	let [value, regtype] = s:get(a:type, a:0)
	call s:set(map([value], expression)[0], regtype)
	call s:repeat(expression)
endfunction

function! s:subpress(type, ...)
	let input = input(':s', '/')
	if input == ''
		return
	endif
	let args = split(input[1:], '\\\@<!'.input[0])
	if len(args) == 2
		let args = args + ['']
	endif
	let [value, regtype] = s:get(a:type, a:0)
	let lines = split(value, "\n")
	call s:set(join(map(lines, 'call("substitute", [v:val] + args)'), "\n"), regtype)
	call s:repeat("\<BS>".input)
endfunction

function! s:get(type, vis)
	let a_reg = s:getreg('a')
	let selection = &selection

	set selection=inclusive
	let selectcmd = "`[v`]"
	if a:vis
		if a:type ==# 'v'
			let selectcmd = "`<v`>"
		elseif a:type ==# 'V'
			let selectcmd = "'<V'>"
		elseif a:type ==# "\<C-V>"
			let selectcmd = "`<\<C-V>`>"
		endif
	else
		if a:type == 'line'
			let selectcmd = "'[V']"
		endif
	endif
	execute 'normal!'.selectcmd.'"ay'
	let value = s:getreg('a')
	let &selection = selection

	call s:setreg('a', a_reg)
	return value
endfunction

function! s:set(value, regtype)
	let a_reg = s:getreg('a')
	let selection = &selection

	set selection=inclusive
	call s:setreg('a', [a:value, a:regtype])
	execute 'normal! gv"ap'

	let &selection = selection
	call s:setreg('a', a_reg)
endfunction

function! s:getreg(regname)
	return [getreg(a:regname), getregtype(a:regname)]
endfunction

function! s:setreg(regname, value)
	call setreg(a:regname, a:value[0], a:value[1])
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
call s:create_map('x', 'g=', '<Plug>(Express)')

call s:create_map('n', 'g:', '<Plug>(Subpress)')
call s:create_map('n', 'g::', '<Plug>(SubpressLine)')
call s:create_map('x', 'g:', '<Plug>(Subpress)')
