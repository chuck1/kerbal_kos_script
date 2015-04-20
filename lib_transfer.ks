
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
	
		launch().
	
		run match_inc(b).
	
		set burn_to_free_return_target to transfer_to_moon_target.
		run burn_to_free_return.
	
		run warp_trans(0).
		
		wait 2.
	
	}
	
	circle(0).
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
				circle(0).
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
	
function transfer_to_planet_nearest {
	
	local orbit_type is calc_obt_type().
	
	if
			(orbit_type = "landed") or
			(orbit_type = "prelaunch") {
		launch(0).
	} else if 	(orbit_type = "suborbit") {
		circle(0).
	} else {
	
		if ship:body = sun {
			print "ship:body is sun".
			print neverset.
		} else {
		
			circle(0).
			
			if ship:body:obt:body = sun {
				print "ship:body is planet".
			} else {
				print "ship:body is moon".
				
				run mvr_match_inc(ship:body:obt:body).
		
				set burn_to_encounter_body to ship:body:obt:body.
				set burn_to_encounter_alt  to 0.
				run burn_to_encounter.
		
				set warp_string to "trans".
				set warp_sub to 0.
				run warp.
			
			}
		}
	
	}
}

function transfer_to_planet {
	declare parameter b.
	
	print "transfer_to_planet " + b.
	
	util_log("transfer_to_planet " + b).
	
	if ship:body = sun {
		print neverset.
	} else if ship:body = b {
	} else if ship:body:obt:body = sun {
		transfer_interplanetary_ejection(b).
	}
	
	if ship:body = b {
	} else {
	
	// long distance approach
	
	set get_capture_alt_body to b.
	run get_capture_alt.
	
	until 0 {
		if ship:body = b {
			if abs((ship:obt:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
				print "satisfactory capture altitude".
				wait 5.
				break.
			}
		} else if ship:obt:hasnextpatch {
			if not (ship:obt:nextpatch:body = b) {
				print "ERROR: nextpatch body is not target body".
				print neverset.
			}
			if abs((ship:obt:nextpatch:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
				print "satisfactory capture altitude".
				wait 5.
				break.
			}
		}
	
		set node_search_target     to b.
		set node_search_use_normal to true.
		set node_search_alt        to get_capture_alt_ret.
		run node_search.
		run node_burn.
	
		if ship:body = transfer_to_planet_target {
			if abs((ship:obt:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
				print "satisfactory capture altitude".
				wait 5.
				break.
			}
			// quarter the distance to periapsis
			set t to (eta:periapsis / 4).
		} else if ship:obt:hasnextpatch {
			if not (ship:obt:nextpatch:body = transfer_to_planet_target) {
				print "ERROR: nextpatch body is not target body".
				print neverset.
			}
	
			if abs((ship:obt:nextpatch:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
				print "satisfactory capture altitude".
				wait 5.
				break.
			}
	
			set t to eta:transition.
	
		
			if eta:transition < (60*60*6) {
				// less than a day to transition
				// warp to transition
				set t to eta:transition + 60.
			} else {
				set t to eta:transition / 2.
			}
		} else {
			set t to eta:apoapsis / 2.
		}
	
		// half the distance to object
		set warp_time_tspan to t.
		run warp_time.
	
	}
	}
	
	
	if ship:body = transfer_to_planet_target {
	} else {
		set warp_string to "trans".
		set warp_sub to 0.
		wait 10.
	}
	
	// should now be in orbit with periapsis close to desired
	
	if ship:body:atm:exists {
		run capture_aerobrake.
		
		if capture_aerobrake_ret = 1 {
			run power_land_atm.
		}
		
	} else {
		run capture(0).
	}
	
	run calc_closest_stable_altitude.
	
	circle(calc_closest_stable_altitude_ret).
}

print "loaded library transfer".


