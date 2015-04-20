declare parameter b.

print "transfer_to_planet " + b.

util_log("transfer_to_planet " + b).

if ship:body = sun {
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

run circle(calc_closest_stable_altitude_ret).


