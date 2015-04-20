declare parameter transfer_to_moon_target.

util_log("transfer_to_moon_low " + transfer_to_moon_target).

if ship:body = transfer_to_moon_target {
	run circle_low.
} else {

	if not (transfer_to_moon_target:obt:body = ship:body) {
	
		set transfer_ip_target to transfer_to_moon_target:obt:body.
		run transfer_ip.

	} else {
		local obt_type is calc_obt_type().
		
		if (obt_type = "prelaunch") or (obt_type = "landed") {
			launch(0).
		} else if (obt_type = "suborbit") or (obt_type = "elliptic") {
			run circle(0).
		} else if obt_type = "circular" {

			run mvr_match_inc(transfer_to_moon_target).

			run burn_to_free_return(transfer_to_moon_target).

			util_warp_trans(0).
			
			wait 2.
		} else {
			print "invalid obt type: " + orbit_type.
			print neverset.
		}
	}
}



