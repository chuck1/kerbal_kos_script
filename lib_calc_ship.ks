
function calc_obt_type {

	run get_highest_peak_here.
	
	set launch_pad to latlng(-0.09722550958395, -74.5576705932617).
	
	set latlng_distance to sqrt((launch_pad:lat - latitude)^2 + (launch_pad:lng - longitude)^2).
	
	if
			(latlng_distance < 10^(-3)) and
			(abs(ship:verticalspeed) < 0.01) and
			(ship:surfacespeed < 0.01) {
		// prelaunch
		return "prelaunch".
	} else if
			(alt:radar < 20) and
			(abs(ship:verticalspeed) < 0.01) and
			(ship:surfacespeed < 0.01) {
		// landed
		return "landed".
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

