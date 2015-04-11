
set get_stable_orbits_body to ship:body.
run get_stable_orbits.

set safe_altitude to get_stable_orbits_ret[0][0] * 1.1.

if periapsis < safe_altitude {

	if ship:verticalspeed > 0 {
	} else {

		lock h to vcrs(
			ship:position - ship:body:position,
			ship:velocity:orbit - ship:body:velocity:orbit).
	
		lock radial to vcrs(prograde:vector, h:normalized):direction.
	
		lock steering to radial.
		run wait_orient.
		
		until periapsis > safe_altitude or ship:verticalspeed > 0 {
			lock throttle to 1.
		}
		lock throttle to 0.

		print "cooldown".
		wait 5.
	}

}



