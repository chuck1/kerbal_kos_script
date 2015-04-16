
set launch_pad to latlng(-0.09722550958395, -74.5576705932617).

set latlng_distance to sqrt((launch_pad:lat - latitude)^2 + (launch_pad:lng - longitude)^2).

if
		(latlng_distance < 10^-5) and
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
} else if periapsis < 0 {
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



