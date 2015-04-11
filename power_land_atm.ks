// preliminaries
sas off.
lock throttle to 0.

set deorbit_body  to sun.
set deorbit_angle to 90.
run deorbit.

// ===============================================================
// variables 
set g to ship:body:mu / ship:body:radius^2.
lock a to ship:maxthrust / ship:mass * cos(ship:facing:pitch).

lock timetostop to -1.0 * ship:verticalspeed / (a - g).

// ===============================================================
print "orient retro".
lock steering to R(ship:srfretrograde:pitch, ship:srfretrograde:yaw, 180).

// ===============================================================

print "wait for descent".
wait until ship:verticalspeed < 0.

lock a0 to vang(up:forevector, ship:srfretrograde:forevector).

lock throttle to 0.

// ===============================================================
// do not burn until pitched up
print "wait for pitch up".
wait until vdot(ship:facing:vector, up:vector) > 0.




set scal1 to 1.0.

lock timetoterm to 0.
lock disttoterm to 0.
lock delvel to 1.

until alt:radar < 2000 {


	if delvel < 0.1 {
		// close to term
		set timetoimpact to alt:radar / ship:termvelocity.
		set meth to 0.
	} else if alt:radar < disttoterm {
		// not going to reach term

		set q to sqrt(ship:verticalspeed^2 + 2.0 * g * alt:radar).
		set t0 to (-1.0 * ship:verticalspeed + q) / -g.
		set t1 to (-1.0 * ship:verticalspeed - q) / -g.

		if t0 < 0 {
			set timetoimpact to t1.
		} else if t1 < 0 {
			set timetoimpact to t0.
		} else {
			set timetoimpact to min(t0, t1).
		}
		set meth to 1.
	} else {
		// going to reach term
		set timetoimpact to timetoterm + (alt:radar - disttoterm) / ship:termvelocity.
		set meth to 2.
	}

	if timetoimpact < (timetostop + 1) {
		print "timetoimpact " + meth + " " + timetoimpact.
		lock throttle to 1.
		wait until ship:verticalspeed > (-0.2 * alt:radar).
		lock throttle to 0.
	}

	wait 0.2.
}

run power_land_arrest_srf_velocity.

run power_land_final.






