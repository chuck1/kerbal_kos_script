// PARAM list_sort_arg
// PARAM list_sort_mode

set ia to 0.

set l to list_sort_arg.

print l.

//print "ia ib va vb test".


until ia = l:length {

	set ib to ia + 1.
	
	until ib = l:length {

		if list_sort_mode = 0 {
			set test to (l[ia] < l[ib]).
		} elseif list_sort_mode = 1 {
			set test to (l[ia] > l[ib]).
		}

		//print ia + " " + ib + " " + l[ia] + " " + l[ib] + " " + test.

		if test {
			break.
		} else {
			set ib to ib + 1.
		}
	}
	
	if ib = (ia + 1) {
		set ia to ia + 1.
	} else {
		print l.
		print "move " + ia + " to " + ib.

		l:insert(ib, l[ia]).
		l:remove(ia).

		set ia to 0.
	}
}

print l.

unset list_sort_arg.
unset list_sort_mode.



// PARAM list_sort_arg

set list_sort_mode to 0.
run list_sort.

// PARAM list_sort_arg

set list_sort_mode to 1.
run list_sort.

