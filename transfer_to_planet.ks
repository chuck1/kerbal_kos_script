
set launch_altitude to 0.
run launch.

if ship:body = sun {
	print "ship:body is sun".
	print neverset.
} else {
	if ship:body:obt:body = sun {
		print "ship:body is planet".
	} else {
		print "ship:body is moon".
		
		set launch_altitude to 0.
		run launch.

		set match_inc_target to ship:body:obt:body.
		run match_inc.

		set burn_to_encounter_body to ship:body:obt:body.
		set burn_to_encounter_alt  to 0.
		run burn_to_encounter.

		set warp_string to "trans".
		set warp_sub to 0.
		run warp.

		
		
	}
}

run calc_closest_stable_altitude.

set circle_altitude to calc_closest_stable_altitude_ret.
run circle.


