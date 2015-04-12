// PARAM add_line_line

set add_line_l to "".
set add_line_i to 0.
until add_line_i = lines_indent {
	set add_line_l to add_line_l + "-".
	set add_line_i to add_line_i + 1.
}
set add_line_l to add_line_l + add_line_line.

lines:add(add_line_l).

unset add_line_line.

