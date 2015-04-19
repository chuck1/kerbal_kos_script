declare parameter transfer_to_moon_target.

util_log("transfer_to_moon_low " + transfer_to_moon_target).

if ship:body = transfer_to_moon_target {
	run circle_low.
} else {

	if not (transfer_to_moon_target:obt:body = ship:body) {
	
		set transfer_ip_target to transfer_to_moon_target:obt:body.
		run transfer_ip.

	} else {
		run calc_classify_obt.
		
		if (orbit_type = "prelaunch") or (orbit_type = "landed") {
			launch(0).
		} else if (orbit_type = "suborbit") or (orbit_type = "elliptic") {
			run circle(0).
		} else if orbit_type = "circular" {
			set mvr_match_inc_target to transfer_to_moon_target.
			run mvr_match_inc.

			set burn_to_free_return_target to transfer_to_moon_target.
			run burn_to_free_return.

			set warp_string to "trans".
			set warp_sub to 0.
			run warp.
			wait 2.
		} else {
			print "invalid obt type: " + orbit_type.
			print neverset.
		}
	}
}



