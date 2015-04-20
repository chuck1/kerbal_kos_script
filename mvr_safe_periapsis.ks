sas off.
rcs off.
set warp to 0.

local orbits is get_stable_orbits_2(ship:body).

set safe_altitude to orbits[0][0].

if periapsis < safe_altitude {

	if ship:verticalspeed > 0 {
	} else {

		lock h to vcrs(
			ship:position - ship:body:position,
			ship:velocity:orbit - ship:body:velocity:orbit).
	
		lock radial to vcrs(prograde:vector, h:normalized):direction.
	
		lock steering to radial.
		util_wait_orient().
	
		set thrott to 0.
		lock throttle to thrott.
		until periapsis > safe_altitude or ship:verticalspeed > 0 {

			clearscreen.
			print "MVR SAFE PERIAPSIS".
			print "============================".
			print "    periapsis  " + periapsis.
			print "    vert speed " + ship:verticalspeed.
			
			set thrott to 1.

			wait 0.1.
		}
		lock throttle to 0.

		print "cooldown".
		wait 5.
	}

}



