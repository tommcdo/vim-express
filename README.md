express.vim
===========

express.vim defines some operators that allow you to change text according to a
VimL expression or a substitution. Once invoked, an expression will be
prompted. In the expression, `v:val` will represent the text being operated on
(similar to Vim's map() function).

Mappings
--------

`g={motion}`

Replace the text defined by {motion} with the value of an expression. The
expression is entered at the command-line after a `=` prompt. The original text
will populate the value of `v:val` within the expression.

`g:{motion}`

Filter the text defined by {motion} through a `:substitute`-like command. This
is basically the same as using `g=` and entering `substitute(v:val, ...)`, but
it's a bit easier (and more familiar) to type. A substitution is entered at the
command-line after a `:s/` prompt. The `/` character in the prompt can be
deleted and replaced with a different delimiter.

Examples
--------

Here are some examples of using the `g=` and `g:` operators. In the examples,
the prompt is included in the Expression column. For `g=` operations, the
prompt is `=`; for `g:` operations, the prompt is `:s/`. The complete operation
is performed by typing the Operator + Motion followed by the Expression
(without the prompt), and then pressing `Enter`.

Note that both operators are repeatable with `.` when [repeat.vim][1] is
installed.

Description | Operator + Motion | Expression | Before | After
--- | --- | --- | --- | ---
Change member names to getters (snake case) | `g=iw` | `=``'get_'.v:val.'()'` | `foo_bar` | `get_foo_bar()`
Change member names to getters (camel case) | `g:iw` | `:s/``.*/get\u\0()/` | `fooBar` | `getFooBar()`
Sort elements of an array literal | `g=i[` | `=``join(sort(split(v:val, ', ')), ', ')` | `[foo, bar, baz]` | `[bar, baz, foo]`
Clean up whitespace around binary operators | `g::` (line) | `:s/``\s*\([=+*\/-]\)\s*/ \1 /g` | `int x=foo   + bar *baz` | `int x = foo + bar * baz`
Comment out a block of code | `g=ip` | `=``'/* '.v:val.' */'` | `int x = 400;`<br/>`int y = 5;` | `/* int x = 400;`<br/>`int y = 5; */`

  [1]: https://github.com/tpope/vim-repeat
