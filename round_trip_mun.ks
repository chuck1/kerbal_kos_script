clearscreen.

if ship:body = mun {
} else if ship:obt:hasnextpatch {
	if ship:obt:nextpatch:body = mun {
		run warp("trans", 0). wait 2.
	} else {
		print "ERROR".
		wait until 0.
	}
} else {
	run launch(80000).

	set target to mun.

	run match_inc(mun).

	set burn_to_free_return_body to mun.
	run burn_to_free_return.

	run warp("trans", 0). wait 2.
}

set power_land_no_atm_body  to sun.
set power_land_no_atm_angle to 90.
run power_land_no_atm.

wait 10.

run launch(10000).

run match_inc(kerbin).

set burn_to_encounter_body to kerbin.
set burn_to_encounter_alt  to 0.
run burn_to_encounter.

run warp("trans", 0).

run power_land_atm.


