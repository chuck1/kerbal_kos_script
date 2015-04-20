
function calc_obt_type {

	run get_highest_peak_here.
	
	set launch_pad to latlng(-0.09722550958395, -74.5576705932617).

	lock landed to ((abs(ship:verticalspeed) < 0.05) and (ship:surfacespeed < 0.05)) and (alt:radar < 1000).
	
	if landed {
		if (launch_pad:distance < 1) and (ship:body = kerbin) {
			// prelaunch
			return "prelaunch".
		} else {
			// landed
			return "landed".
		}
	} else if periapsis < get_highest_peak_ret {
		// suborbital
		return "suborbit".
	} else {
		// orbit
		if ship:obt:eccentricity < 0.1 {
			return "circular".
		} else {
			return "elliptic".
		}
	}

}

print "loaded library lib_calc_ship".

