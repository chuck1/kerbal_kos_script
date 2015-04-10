//declare parameter deorbit_no_atm_body.
//declare parameter deorbit_no_atm_angle.


print "DEORBIT NO ATM ---------------------------".
print "body:       " + deorbit_body.
print "angle:      " + deorbit_angle.
print "periapsis:  " + periapsis.
print "apoapsis:   " + apoapsis.

if periapsis > 10000 {

	print "burn to suborbital trajectory".

	if periapsis < (ship:body:radius / 4) {
		print "periapsis is below (radius/4)".
		set circle_alt to periapsis.
		run circle.
	} else {
		print "periapsis is above (radius/4)".
		set circle_alt to ship:body:radius / 4.
		run circle.
	}

	set peri_target to -1 * ship:altitude.

	print "periapsis target = " + peri_target.

	set wait_for_angle_body  to deorbit_body.
	set wait_for_angle_angle to deorbit_angle.
	run wait_for_angle.

	lock steering to retrograde.
	run wait_orient.

	lock throttle to 1.
	wait until periapsis < peri_target.
	lock throttle to 0.

	wait 5.
}
