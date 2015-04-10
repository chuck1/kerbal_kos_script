// PARAM transfer_ip_body_2

set target to transfer_ip_body_2.

if ship:body = sun {
} else if ship:body = transfer_ip_body_2 {
} else {

	// get into stable circular orbit around planet.
	run transfer_to_planet.

	set body_1 to ship:body.
	set body_2 to transfer_ip_body_2.

	set calc_transfer_ip_body_2 to transfer_ip_body_2.
	run calc_transfer_ip.

	set wait_for_angle_body_1    to body_1.
	set wait_for_angle_body_2    to body_2.
	set wait_for_angle_body_axis to sun.
	set wait_for_angle_angle     to calc_transfer_ip_phase.
	run wait_for_angle.


	set match_inc_body to body_2.
	run match_inc.


	set wait_for_angle_body_1    to ship.
	set wait_for_angle_body_2    to sun.
	set wait_for_angle_body_axis to body_1.
	set wait_for_angle_angle     to calc_transfer_ip_theta + 90.
	run wait_for_angle.

	set burn_deltav to calc_transfer_ip_ejection_burn.
	run burn.

	set warp_sub to 0.
	set warp_string to "trans".
	run warp.
	
	// get safe distance from body_1
	set warp_time_tspan to 3600.
	run warp_time.
}

if ship:body = transfer_ip_body_2 {
} else {

// long distance approach

set get_capture_alt_body to transfer_ip_body_2.
run get_capture_alt.

until 0 {
	if ship:body = transfer_ip_body_2 {
		if abs((ship:obt:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
			print "satisfactory capture altitude".
			wait 5.
			break.
		}
	} else if ship:obt:hasnextpatch {
		if not (ship:obt:nextpatch:body = transfer_ip_body_2) {
			print "ERROR: nextpatch body is not target body".
			print neverset.
		}
		if abs((ship:obt:nextpatch:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
			print "satisfactory capture altitude".
			wait 5.
			break.
		}
	}

	set node_search_target     to transfer_ip_body_2.
	set node_search_use_normal to true.
	set node_search_alt        to get_capture_alt_ret.
	run node_search.
	run node_burn.

	if ship:body = transfer_ip_body_2 {
		if abs((ship:obt:periapsis - get_capture_alt_ret) / get_capture_alt_ret) < 0.01 {
			print "satisfactory capture altitude".
			wait 5.
			break.
		}
		// quarter the distance to periapsis
		set t to (eta:periapsis / 4).
	} else if ship:obt:hasnextpatch {
		if not (ship:obt:nextpatch:body = transfer_ip_body_2) {
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


if ship:body = transfer_ip_body_2 {
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

set circle_altitude to apoapsis.
run circle.





