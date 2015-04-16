//declare parameter capture_altitude.

if capture_altitude = 0 {
	run calc_closest_stable_altitude.

	set capture_altitude to calc_closest_stable_altitude_ret.
}

print "CAPTURE ----------------------------------".
print "burn to:    " + capture_altitude.

lock accel_max to ship:maxthrust / ship:mass.

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
	
	set deltav_alt  to periapsis.
	set deltav_alt1 to apoapsis.
	set deltav_alt2 to capture_altitude.
	run deltav.

	set v0 to ship:velocity:orbit:mag.
	lock dv_rem to dv - (ship:velocity:orbit:mag - v0).
	lock est_rem_burn to abs(dv_rem / accel_max).
	
	if eta:periapsis > 0 { // not yet reached periapsis
		set warp_string to "per".
		set warp_sub to (est_rem_burn/2 + 11).
		run warp.
	}
	
	lock steering to retrograde.
	run wait_orient.
	
	set th to 0.
	lock throttle to th.
	until not (ship:obt:hasnextpatch) {
		
		run lines_print_and_clear.
		print "CAPTURE".
		print "================================".
		print "    apoapsis     " + apoapsis.
		print "    est rem burn " + est_rem_burn.
		
		set th to (est_rem_burn / 5 + 0.1).
	}
	
	print "captured".
	
	wait until apoapsis < (capture_alt * 1.1) or aop_change > 180.
	print "burn complete".
	
	lock throttle to 0.
	print "cooldown".
	wait 5.
}


// reset defaults
set capture_altitude to 0.




