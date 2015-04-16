
run kos_init.

if ship:body = kerbin {
} else {
	set transfer_to_target to kerbin.
	
	if ship:obt:hasnextpatch {
	} else {
		run launch.
	
		set match_inc_body to kerbin.
		run match_inc.

		set burn_to_encounter_body to kerbin.
		set burn_to_encounter_alt  to 0.
		run burn_to_encounter.
	}

	set warp_string to "trans".
	set warp_sub to 0.
	run warp("trans", 0).
}


run power_land_atm.



