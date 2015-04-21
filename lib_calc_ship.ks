
function calc_obt_type {
	parameter x.
	
	run get_highest_peak_here.
	
	set launch_pad to latlng(-0.09722550958395, -74.5576705932617).
	
	lock landed to ((abs(x:verticalspeed) < 0.05) and (x:surfacespeed < 0.05)) and (alt:radar < 1000).
	
	if landed {
		if (launch_pad:distance < 1) and (x:body = kerbin) {
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
		if x:obt:eccentricity < 0.1 {
			return "circular".
		} else if x:obt:eccentricity >= 1 {
			return "hyperbolic".
		} else {
			return "elliptic".
		}
	}

}

print "loaded library lib_calc_ship".

