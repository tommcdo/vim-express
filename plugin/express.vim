function! s:express_base(expression, type, vis)
	let expression = a:expression
	if expression == ''
		return
	endif
	if expression =~? '^\([gswbv]:\)\?[a-z][a-z0-9#:_]\+$'
		let expression = expression.'(v:val)'
	elseif expression =~? '^!'
		let expression = 'system("'.escape(expression[1:], '"\').'", v:val)'
	endif
	let [value, regtype] = s:get(a:type, a:vis)
	call s:set(map([value], expression)[0], regtype)
endfunction

function! s:express(type, ...)
	call s:custom_setup(-1)
	let expression = input('=', '', 'expression')
	call s:express_base(expression, a:type, a:0)
	call s:repeat(expression."\<CR>".s:get_capture())
endfunction

function! s:express_custom(type, ...)
	call s:express_base(s:express_custom[s:express_index], a:type, a:0)
	call s:repeat(s:get_capture())
endfunction

function! s:subpress_base(input, type, vis)
	let input = a:input
	if input == ''
		return
	endif
	let args = split(input[1:], '\\\@<!'.input[0])
	if len(args) == 2
		let args = args + ['']
	endif
	let [value, regtype] = s:get(a:type, a:vis)
	let lines = split(value, "\n")
	call s:set(join(map(lines, 'call("substitute", [v:val] + args)'), "\n"), regtype)
endfunction

function! s:subpress(type, ...)
	call s:custom_setup(-1)
	let input = input(':s', '/')
	call s:subpress_base(input, a:type, a:0)
	call s:repeat("\<BS>".input."\<CR>".s:get_capture())
endfunction

function! s:subpress_custom(type, ...)
	call s:subpress_base(s:express_custom[s:express_index], a:type, a:0)
	call s:repeat(s:get_capture())
endfunction

function! express#capture(input, ...)
	let suffix = join(a:000, '')
	let s:express_capture .= a:input.suffix
	let s:express_captures += [a:input]
	return a:input
endfunction

function! express#recall(index)
	return get(s:express_captures, a:index, '')
endfunction

function! s:get_capture()
	return s:express_capture
endfunction

function! s:custom_setup(index)
	let s:express_capture = ''
	let s:express_index = a:index
	let s:express_captures = ['']
endfunction

function! s:custom_maps(op, mapping)
	let words = split(a:mapping)
	let lhs = words[0]
	let rhs = join(words[1:])
	if !exists('s:express_custom')
		let s:express_custom = []
	endif
	let s:express_custom += [rhs]
	execute 'nnoremap <silent>' lhs ':<C-U>call <SID>custom_setup('.(len(s:express_custom) - 1).')<CR>:set operatorfunc=<SID>'.a:op.'_custom<CR>g@'
	execute 'xnoremap <silent>' lhs ':<C-U>call <SID>custom_setup('.(len(s:express_custom) - 1).')<CR>:call <SID>'.a:op.'_custom(visualmode(), 1)<CR>g@'
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
	silent! call repeat#set("\<Plug>(ExpressRepeat)".a:input)
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

command! -nargs=+ MapExpress call s:custom_maps('express', <q-args>)
command! -nargs=+ MapSubpress call s:custom_maps('subpress', <q-args>)

if exists('g:express_no_mappings')
	finish
endif

call s:create_map('n', 'g=', '<Plug>(Express)')
call s:create_map('n', 'g==', '<Plug>(ExpressLine)')
call s:create_map('x', 'g=', '<Plug>(Express)')

call s:create_map('n', 'g:', '<Plug>(Subpress)')
call s:create_map('n', 'g::', '<Plug>(SubpressLine)')
call s:create_map('x', 'g:', '<Plug>(Subpress)')
