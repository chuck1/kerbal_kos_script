
run get_highest_peak_here.

set launch_pad to latlng(-0.09722550958395, -74.5576705932617).

set latlng_distance to sqrt((launch_pad:lat - latitude)^2 + (launch_pad:lng - longitude)^2).

print "latlng dist " + latlng_distance.

if
		(latlng_distance < 10^-3) and
		(abs(ship:verticalspeed) < 0.01) and
		(ship:surfacespeed < 0.01) {
	// prelaunch
	set orbit_type to "prelaunch".
} else if
		(alt:radar < 20) and
		(abs(ship:verticalspeed) < 0.01) and
		(ship:surfacespeed < 0.01) {
	// landed
	set orbit_type to "landed".
} else if periapsis < get_highest_peak_ret {
	// suborbital
	set orbit_type to "suborbit".
} else {
	// orbit
	if ship:obt:eccentricity < 0.1 {
		set orbit_type to "circular".
	} else {
		set orbit_type to "elliptic".
	}
}

//print orbit_type.
//wait 10.


