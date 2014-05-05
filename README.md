express.vim
===========

express.vim defines an operator, `g=`, that allows you to change text according
to a VimL expression. Once invoked, an expression will be prompted. In the
expression, `v:val` will represent the text being operated on (similar to Vim's
map() function).

Mappings
--------

`g={motion}`

Replace the text defined by {motion} with the value of an expression. The
expression is entered at the command-line (with an '=' prompt). The original
text will populate the value of `v:val` within the expression.

`g:{motion}`

Filter the text defined by {motion} through a `:subsitute`-like command. This
is basically the same as using `g=` and entering `substitute(v:val, ...)`, but
it's a bit easier (and more familiar) to type.

Examples
--------

Consider the following text:

    Hi, my name is "john jones"

With your cursor inside the quoted string, type `g=i"` and then input the
following expression on the prompt:

    substitute(v:val, '\<.', '\U\0', 'g')

The resulting text will be:

    Hi, my name is "John Jones"
