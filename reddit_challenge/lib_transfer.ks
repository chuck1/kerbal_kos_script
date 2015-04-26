
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

	warp_trans(0).
	
	// get safe distance from body_1
	warp_time(3600).
}
function transfer_to_moon {
	declare parameter b.
	declare parameter alt0.

	if alt0 = "low" {
		set alt0 to calc_obt_alt_low(b).
	}
	
	util_log("transfer_to_moon_low " + b).
	
	if ship:body = b {
		circle(alt0).
	} else {
		if not (b:obt:body = ship:body) {
		
			transfer_ip(b:obt:body).
	
		} else {
			local obt_type is calc_obt_type(ship).
			
			if (obt_type = "prelaunch") or (obt_type = "landed") {
				launch(0).
			} else if (obt_type = "suborbit") or (obt_type = "elliptic") {
				circle(0).
			} else if obt_type = "circular" {
				mvr_match_inc(b).
				burn_to_encounter(b).
				warp_trans(0).
				wait 2.
				mvr_adjust_per(alt0).
			} else {
				print "invalid obt type: " + orbit_type.
				print neverset.
			}
		}
	}
}

function transfer_to {
	declare parameter b.
	declare parameter alt0.

	print "transfer_to " + b + " " + alt0.
	util_log("transfer_to " + b + " " + alt0).

	if b = sun {
		print neverset.
	} else if b:obt:body = sun {
		transfer_to_planet(b, alt0).
	} else if b:obt:body:obt:body = sun {
		transfer_to_moon(b, alt0).
	}

	if (calc_obt_type(ship) = "circular") and (ship:body = b) {
		return 0.
	}

	//return 1. error: wrong # of args
	reboot.
}
function transfer_to_planet_nearest {
	
	local orbit_type is calc_obt_type(ship).
	
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
				
				mvr_match_inc(ship:body:obt:body).
		
				run burn_to_encounter(ship:body:obt:body, 0).
		
				warp_trans(0).
			
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
			warp_time(t).
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
		capture_aerobrake().
		
		if capture_aerobrake_ret = 1 {
			power_land_atm().
		}
		
	} else {
		capture(0).
	}
	
	circle(calc_closest_stable_altitude(ship)).
}



print "loaded library transfer".


