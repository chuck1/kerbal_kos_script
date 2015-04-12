//declare parameter circle_altitue.
//declare parameter precision.

if circle_altitude = 0 {
	run calc_closest_stable_altitude.
	set circle_altitude to calc_closest_stable_altitude_ret.
}


print "CIRCLE -----------------------------------".
print "altitue:         " + circle_altitude.
print "periapsis:       " + periapsis.
print "apoapsis:        " + apoapsis.



set precision to 0.2.

//set mvr_adjustcle_precision

lock error_max to max(
	abs((apoapsis  - circle_altitude)/circle_altitude),
	abs((periapsis - circle_altitude)/circle_altitude)).

if ship:obt:hasnextpatch {
	set capture_alt to circle_altitude.
	run capture.
}

set mvr_adjust_altitude to circle_altitude.

until error_max < precision {
	
	print "altitude error: " + (error_max*100) + "%".

	run mvr_safe_periapsis.

	if ship:verticalspeed > 0 {
		run mvr_adjust_at_apoapsis.
	} else if ship:verticalspeed < 0 {
		run mvr_adjust_at_periapsis.
	}
	
}

print "orbit is circularized".

// reset default
set circle_altitude to 0.



