run kos_init.

set go_to_dest to mun_arch.
run go_to.

if go_to_complete {
	set mission_complete to true.
	print "go_to complete".
}



