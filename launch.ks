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

	print "launch!".
	lock throttle to 0.8.
	lock steering to up + R(0,0,180).

	if ship:maxthrust = 0 {
		stage.
	}

	if legs {
		set legs to false.
	}

	when stage:liquidfuel < 0.001 then {
	    stage.
	    preserve.
	}

	if ship:body:atm:exists {
	
		if periapsis > ship:body:atm:height {
			print "already in orbit".
		} else {

			lock P to ship:termvelocity - ship:verticalspeed.
			set th to 0.
			lock throttle to th.
	
			set kd to 0.01.

			lock pres to ship:body:atm:sealevelpressure * ( constant():e ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).
	
			until pres < 0.12 {
				set th to P * kd.
				wait 0.1.
			}
	
			print "gravity turn".
			lock throttle to 1.
			lock steering to up + R(0,0,180) + R(0,-45,0).
	
			wait until ship:apoapsis > launch_altitude.

			print "coast".
			lock throttle to 0.
			wait until ship:control:pilotmainthrottle = 0.
		}

	} else {
		lock throttle to 1.
	
		lock steering to up + R(0,0,180) + R(0,-45,0).
	
		wait until apoapsis > r.
	
		print "coast".
		print "cooldown".
		lock throttle to 0.
		wait 5.
	}
}

if apoapsis > launch_altitude {
	set circle_altitude to apoapsis.
	run circle.
} else {
	set circle_altitude to launch_altitude.
	run circle.
}



