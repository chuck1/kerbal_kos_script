function transfer_interplanetary_ejection {
	parameter b.

	if not (ship:body:obt:body = sun) {
		print "ship:body must be a planet".
		print neverset.
	}

	if ship:body = sun {
		print "not implemented".
		print neverset.
	}
	
	if ship:body = b {
		// already there
		return.
	}

		
	
	// get into stable circular orbit around nearest planet.
	run transfer_to_planet_nearest.

	set body_2 to transfer_to_planet_target.

	set calc_transfer_to_planet_target to transfer_to_planet_target.
	run calc_transfer_to_planet.

	run wait_for_angle(ship:body, body_2, sun, calc_transfer_to_planet_phase).

	run mvr_match_inc(body_2).

	run wait_for_angle(ship, sun, ship:body, calc_transfer_to_planet_theta + 90).

	set burn_deltav to calc_transfer_to_planet_ejection_burn.
	run burn.

	util_warp_trans(0).
	
	// get safe distance from body_1
	run warp_time(3600).
}


function transfer_to_moon {
	parameter b.
	
	if ship:body = b {
	} else {
	
		if not (b:obt:body = ship:body) {
		
			set transfer_ip_target to transfer_to_moon_target:obt:body.
			run transfer_ip.
	
		}
	
		run launch.
	
		set match_inc_target to transfer_to_moon_target.
		run match_inc.
	
		set burn_to_free_return_target to transfer_to_moon_target.
		run burn_to_free_return.
	
		set warp_string to "trans".
		set warp_sub to 0.
		run warp.
		wait 2.
	
	}
	
	run circle(0).
}
function transfer_to_moon_low {
	parameter b.
	
	util_log("transfer_to_moon_low " + b).
	
	if ship:body = b {
		run circle_low.
	} else {
	
		if not (b:obt:body = ship:body) {
		
			set transfer_ip_target to transfer_to_moon_target:obt:body.
			run transfer_ip.
	
		} else {
			local obt_type is calc_obt_type().
			
			if (obt_type = "prelaunch") or (obt_type = "landed") {
				launch(0).
			} else if (obt_type = "suborbit") or (obt_type = "elliptic") {
				run circle(0).
			} else if obt_type = "circular" {
	
				run mvr_match_inc(b).
	
				run burn_to_free_return(b).
	
				util_warp_trans(0).
				
				wait 2.
			} else {
				print "invalid obt type: " + orbit_type.
				print neverset.
			}
		}
	}
}


function transfer_to {
	parameter transfer_to_target.
	parameter is_boot_func.

	print "transfer_to".

	if transfer_to_target = sun {
		print neverset.
	} else if transfer_to_target:obt:body = sun {
		run transfer_to_planet(transfer_to_target).
	} else if transfer_to_target:obt:body:obt:body = sun {
		transfer_to_moon(transfer_to_target).
	}

	if is_boot_func {
		if (calc_obt_type() = "circular") and (ship:body = transfer_to_target) {
			set mission_complete to true.
		}
	}
}
	

print "loaded library transfer".

