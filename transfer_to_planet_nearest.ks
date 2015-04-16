
run calc_classify_obt.

if
		(orbit_type = "landed") or
		(orbit_type = "prelaunch") {
	run launch.
} else if 	(orbit_type = "suborbit") {
	run circle.
} else {

	if ship:body = sun {
		print "ship:body is sun".
		print neverset.
	} else {
	
		run circle.
		
		if ship:body:obt:body = sun {
			print "ship:body is planet".
		} else {
			print "ship:body is moon".
			
			set mvr_match_inc_target to ship:body:obt:body.
			run mvr_match_inc.
	
			set burn_to_encounter_body to ship:body:obt:body.
			set burn_to_encounter_alt  to 0.
			run burn_to_encounter.
	
			set warp_string to "trans".
			set warp_sub to 0.
			run warp.
		
		}
	}

}



