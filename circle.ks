//declare parameter circle_altitue.
//declare parameter precision.

sas off.
rcs off.
set warp to 0.


if circle_altitude = 0 {
	run calc_closest_stable_altitude.
	set circle_altitude to calc_closest_stable_altitude_ret.
}

run log("circle " + circle_altitude).

set lines_add_line to "CIRCLE " + circle_altitude.
run lines_add.
set lines_indent to lines_indent + 1.


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


//until error_max < precision {
if error_max < precision {
	print "orbit is circular".
	wait 5.
} else {
	
	run mvr_safe_periapsis.

	if ship:verticalspeed > 0 {
		run mvr_adjust_at_apoapsis.
	} else if ship:verticalspeed < 0 {
		run mvr_adjust_at_periapsis.
	}
	
}


// reset default
set circle_altitude to 0.
set lines_indent to lines_indent - 1.



