clearscreen.

run global_var.

if ship:body = mun {
} else if ship:obt:hasnextpatch {
	if ship:obt:nextpatch:body = mun {
		set warp_string to "trans".
		set warp_sub to 0.
		run warp.
		wait 2.
	} else {
		print "ERROR".
		wait until 0.
	}
} else {
	run launch(200000).

	set target to mun.

	set match_inc_body to mun.
	run match_inc.

	set burn_to_free_return_body to mun.
	run burn_to_free_return.

	set warp_string to "trans".
	set warp_sub to 0.
	run warp.
	wait 2.
}

set power_land_no_atm_body  to sun.
set power_land_no_atm_angle to 90.
run power_land_no_atm.

set go_to_dest to mun_arch.
run go_to.












