
print "deorbit".

set peri_target to ship:body:atm:height * 0.5.

if periapsis > ship:body:atm:height {

	if periapsis < (ship:body:radius / 4) {
		circle(periapsis).
	} else {
		circle(ship:body:radius / 4).
	}



	print "periapsis target = " + peri_target.

	run wait_for_angle(ship, deorbit_body, ship:body, deorbit_angle).

	lock steering to retrograde.
	util_wait_orient().

	lock throttle to 1.
	wait until periapsis < peri_target.
	lock throttle to 0.

	wait 5.

}



