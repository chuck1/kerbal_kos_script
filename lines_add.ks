// PARAM lines_add_line

set lines_add_l to "".
set lines_add_i to 0.
until lines_add_i = lines_indent {
	set lines_add_l to lines_add_l + "-".
	set lines_add_i to lines_add_i + 1.
}
set lines_add_l to lines_add_l + lines_add_line.

lines:add(lines_add_l).

unset lines_add_line.

