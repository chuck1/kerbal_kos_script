// PARAMETER launch_altitude

set get_stable_orbits_body to ship:body.
run get_stable_orbits.

rcs off.

if launch_altitude = 0 {
	set launch_altitude to ship:body:radius / 5.
}

if periapsis > get_stable_orbits_ret[0][0] {
	print "already in orbit".
} else {
	if ship:body:atm:exists {
		run launch_atm.
	} else {
		run launch_no_atm.
	}
}

if apoapsis > launch_altitude {
	set circle_altitude to apoapsis.
	run circle.
} else {
	set circle_altitude to launch_altitude.
	run circle.
}



