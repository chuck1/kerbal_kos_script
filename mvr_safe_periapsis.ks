sas off.
rcs off.
set warp to 0.

set get_stable_orbits_2_body to ship:body.
run get_stable_orbits_2.

set safe_altitude to get_stable_orbits_2_ret[0][0].

if periapsis < safe_altitude {

	if ship:verticalspeed > 0 {
	} else {

		lock h to vcrs(
			ship:position - ship:body:position,
			ship:velocity:orbit - ship:body:velocity:orbit).
	
		lock radial to vcrs(prograde:vector, h:normalized):direction.
	
		lock steering to radial.
		run wait_orient.
	
		set thrott to 0.
		lock throttle to thrott.
		until periapsis > safe_altitude or ship:verticalspeed > 0 {

			run lines_print_and_clear.
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



