//declare parameter capture_altitude.

if capture_altitude = 0 {
	run calc_closest_stable_altitude.

	set capture_altitude to calc_closest_stable_altitude_ret.
}

print "CAPTURE ----------------------------------".
print "burn to:    " + capture_altitude.

set aop to ship:obt:argumentofperiapsis.

lock aop_change to abs(aop - ship:obt:argumentofperiapsis).

lock normal to vcrs(
	ship:position - ship:body:position,
	ship:velocity:orbit):normalized.

lock radial to vcrs(prograde:vector, normal):direction.


// if escape trajectory, burn until capture
if ship:obt:hasnextpatch {

	if periapsis < 0 {
		print "avoid collision with " + ship:body. wait 3.

		lock steering to radial.
		run wait_orient.		

		lock throttle to 0.1.
		wait until periapsis > capture_altitude.
		lock throttle to 0.
		
		print "cooldown".
		wait 5.	
	}
	
	print "perform capture".
	
	run deltav(periapsis, apoapsis, capture_altitude).
	
	run calc_burn_time(dv).
	
	if eta:periapsis > 0 { // not yet reached periapsis
		set warp_string to "per".
		set warp_sub to (burn_time_return/2 + 11).
		run warp.
	}
	
	lock steering to retrograde.
	run wait_orient.

	lock throttle to 1.
	
	wait until not (ship:obt:hasnextpatch).
	print "captured".

	wait until apoapsis < (capture_alt * 1.1) or aop_change > 180.
	print "burn complete".
	
	lock throttle to 0.

	print "cooldown".
	wait 5.
}


// reset defaults
set capture_altitude to 0.




