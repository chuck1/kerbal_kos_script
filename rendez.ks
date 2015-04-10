

// orbital planes now match

if target:obt:eccentricity > 1.1 {
	// eccentric
	// be lazy and just rendezvous at target apoapsis
	
	run circle(target:apoapsis, 0.01).

	// ship ta at target apoapsis
	lock ta0 to 
		target:argumentofperiapsis
		- ship:argumentofperiapsis + 180.
	
	if ta0 < 0 {
		lock ta to ta0 + 360.
	} else if ta0 > 360 {
		lock ta to ta0 - 360.
	} else {
		lock ta to ta0.
	}

	// sweep to target apoapsis
	lock swp0 to ta - ship:obt:trueanomaly.
	
	if swp0 < 0 {
		lock swp to swp0 + 360.
	} else if swp0 > 360 {
		lock swp to swp0 - 360.
	} else {
		lock swp to swp0.
	}

	// ship eta to target apoapsis
	set E_s to swp / 360 * ship:obt:period.
	
	// target eta to target apo when ship is at apo
	lock E_t_0 to target:eta:apoapsis - E_s.

	if E_t_0 < 0 {
		lock E_t to E_t_0 + target:obt:period.
	} else {
		lock E_t to E_t_0.
	}
	
	// for now just choose K_s
	set K_s to 10.

	// using old P_s
	set K_t to (K_s * P_s - E_t) / P_t.
	
	set K_t to round(K_t, 0).
	
	// desired ship period
	P_s = (K_t * P_t + E_t) / K_s

	if P_s > ship:obt:period {
		lock steering to prograde.
		lock error to P_s - ship:obt:period.
		set w_str to "per".
	} else {
		lock steering to retrograde.
		lock error to ship:obt:period - P_s.
		set w_str to "apo".
	}
	
	run warp_time(E_s).

	run wait_orient.

	print "burn".

	set th to 0.
	lock throttle to th.
	until error < 0 {
		set th to 1.
	}
	set th to 0.
	lock throttle to 0.
	
	print "burn complete".

	run warp_time((K_s - 0.5) * ship:obt:period).
	
	run warp(w_str, 120).
} else {
	// circular

	run circle(ship:apoapsis, 0.01).

	run wait_for_transfer_window.
	
	run burn_to(target:altitude, 0.01).
	
	if ship:altitude < target:altitude {	
		run warp("apo", 120).
	} else {
		run warp("per", 120).
	}
}

run rendez_approach.

run rendez_final.



