// PARAM transfer_to_planet_target

set lines_add_line to ("TRANSFER TO PLANET " + transfer_to_planet_target).
run lines_add.
set lines_indent to lines_indent + 1.

if ship:body = sun {
} else if ship:body = transfer_to_planet_target {
} else {

	// get into stable circular orbit around nearest planet.
	run transfer_to_planet.

	set body_1 to ship:body.
	set body_2 to transfer_to_planet_target.

	set calc_transfer_to_planet_target to transfer_to_planet_target.
	run calc_transfer_to_planet.

	set wait_for_angle_body_1    to body_1.
	set wait_for_angle_body_2    to body_2.
	set wait_for_angle_body_axis to sun.
	set wait_for_angle_angle     to calc_transfer_to_planet_phase.
	run wait_for_angle.


	set mvr_match_inc_target to body_2.
	run mvr_match_inc.


	set wait_for_angle_body_1    to ship.
	set wait_for_angle_body_2    to sun.
	set wait_for_angle_body_axis to body_1.
	set wait_for_angle_angle     to calc_transfer_to_planet_theta + 90.
	run wait_for_angle.

	set burn_deltav to calc_transfer_to_planet_ejection_burn.
	run burn.

	set warp_sub to 0.
	set warp_string to "trans".
	run warp.
	
	// get safe distance from body_1
	set warp_time_tspan to 3600.
	run warp_time.
}

if ship:body = transfer_to_planet_target {
} else {

// long distance approach

set get_capture_alt_body to transfer_to_planet_target.
run get_capture_alt.

until 0 {
	if ship:body = transfer_to_planet_target {
		if abs((ship:obt:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
			print "satisfactory capture altitude".
			wait 5.
			break.
		}
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
	}

	set node_search_target     to transfer_to_planet_target.
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
	run capture.
}

run calc_closest_stable_orbit.

set circle_altitude to calc_closest_stable_orbit_ret.
run circle.

// cleanup
set lines_indent to lines_indent - 1.
unset transfer_to_planet_target.

