

print "deorbit".

set peri_target to ship:body:atm:height * 0.5.

if periapsis > ship:body:atm:height {

	if periapsis < (ship:body:radius / 4) {
		set circle_alt to periapsis.
		run circle.
	} else {
		set circle_alt to (ship:body:radius / 4).
		run circle.
	}



	print "periapsis target = " + peri_target.

	set wait_for_angle_body_1    to ship.
	set wait_for_angle_body_2    to deorbit_body.
	set wait_for_angle_body_axis to ship:body.
	set wait_for_angle_angle     to deorbit_angle.
	run wait_for_angle.

	lock steering to retrograde.
	run wait_orient.

	lock throttle to 1.
	wait until periapsis < peri_target.
	lock throttle to 0.

	wait 5.

}



