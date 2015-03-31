express.vim
===========

Express yourself with custom operators. Define your own operators that apply
either a VimL expression or a substitution to any motion or text object.

Custom operators
----------------

# Express

Expression opertors are created using the `:MapExpress` command. The expression
makes use of the `v:val` placeholder, which contains the text covered by the
given motion, and returns a string.

For example, to create an operator `cd` that surrounds a motion in C-style
comment delimiters, you can use the following command:

    :MapExpress cd '/* ' . v:val . ' */'

Now you can use the new operator `cd` on any motion or text object, such as
`cdiw` to comment out a word, or `cdi(` to comment out everything inside
parentheses.

# Subpress

Substitution operators are created using the `:MapSubpress` command. The
substitution takes a form much like that of the `:substitute` command. It
contains a search pattern, a replacement, and flags, each surrounded by some
delimiter.

As an example, to create an operator `yc` that capitalizes each word of a
motion, you can use the following command:

    :MapSubpress yc /\<\w/\u\0/g

Now you can use the `yc` operator on any motion or text object, such as `yc)`
to capitalize from the cursor to the beginning of the next sentence, or `ycap`
to capitalize every word in the sentence.

# NOTE

At the time of loading your `.vimrc` file, the commands `:MapExpress` and
`:MapSubpress` will likely not have been defined yet. To create operators using
these commands in your `.vimrc`, you can use the `VimEnter` event, for example:

    autocmd VimEnter * MapExpress cd '/*' . v:val . ' */'

Ad-lib operators
----------------

Sometimes you just want to do a one-off (but repeatable) operation using a VimL
expression or substitution. The `g=` and `g:` operators will let you do just
that.

# `g={motion}`

Replace the text defined by {motion} with the value of an expression. The
expression is entered at the command-line after a `=` prompt. The original text
will populate the value of `v:val` within the expression.

# `g:{motion}`

Filter the text defined by {motion} through a `:substitute`-like command. This
is basically the same as using `g=` and entering `substitute(v:val, ...)`, but
it's a bit easier (and more familiar) to type. A substitution is entered at the
command-line after a `:s/` prompt. The `/` character in the prompt can be
deleted and replaced with a different delimiter.

# Examples

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
