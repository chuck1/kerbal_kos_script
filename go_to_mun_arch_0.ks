run kos_init.

set go_to_dest to mun_arch.
run go_to.

if not go_to_complete {
	reboot.
} else {
	print "go_to complete".
}



