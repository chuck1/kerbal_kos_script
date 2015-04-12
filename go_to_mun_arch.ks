run kos_init.

if ship:body = mun and ship:verticalspeed < 0.01 and alt_radar < 10 {
	// landed on mun
} else {

	run transfer_to_mun_low.

	set mvr_flyover_gc to mun_arch[0].
	run mvr_flyover.

}

set go_to_dest to mun_arch.
run go_to.










