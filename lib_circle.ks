
function circle {
	parameter circle_altitude.

	local precision is 0.05.

	print "circle " + circle_altitude.
	util_log("circle " + circle_altitude).

	if circle_altitude = 0 {
		set circle_altitude to calc_closest_stable_altitude().
	}
	if circle_altitude = "low" {
		set circle_altitude to calc_obt_alt_low(ship:body).
	}

	// when apoapsis and periapsis are close, just burn
	if abs((apoapsis - periapsis) / periapsis) < precision {
		burn_to(circle_altitude).
	}

	local obt_type is calc_obt_type(ship).

	if (obt_type = "landed") or (obt_type = "prelaunch") {
		launch(circle_altitude).
		return 1.
	}

	sas off.
	rcs off.
	set warp to 0.
	
	
	set precision to 0.2.
	
	if ship:obt:hasnextpatch {
		capture(circle_altitude).
	}
	
	set mvr_adjust_altitude to circle_altitude.
	
	lock circle_error_apoapsis  to abs((apoapsis  - circle_altitude) / (ship:obt:semimajoraxis)).
	lock circle_error_periapsis to abs((periapsis - circle_altitude) / (ship:obt:semimajoraxis)).

	lock apo_good to (circle_error_apoapsis < 0.01).
	lock per_good to (circle_error_periapsis < 0.01).
	
	if		(ship:obt:eccentricity < 0.05) and
			(apo_good) and (per_good) {
		print "orbit is circular".
		print "apoapsis  " + apoapsis.
		print "periapsis " + periapsis.
		print "err apo   " + circle_error_apoapsis.
		print "err per   " + circle_error_periapsis.
		print "alt       " + circle_altitude.
		print "semimajor " + ship:obt:semimajoraxis.
		return 0.
	} else {
		
		mvr_safe_periapsis().
		
		print "eta:apoapsis  " + eta:apoapsis.
		print "eta:periapsis " + eta:periapsis.
		print "err apo       " + circle_error_apoapsis.
		print "err per       " + circle_error_periapsis.
		//wait 10.
		
		if ship:verticalspeed > 0 {
			
			if per_good {
				mvr_adjust_at_periapsis(circle_altitude).
			} else {
				mvr_adjust_at_apoapsis(circle_altitude).
			}
			
		} else if ship:verticalspeed < 0 {
	
			if apo_good {
				mvr_adjust_at_apoapsis(circle_altitude).
			} else {
				mvr_adjust_at_periapsis(circle_altitude).
			}
	
		}
		
	}
	reboot.	
	//return 1. error: wrong # of args
}
function circle_low {
	util_log("circle_low").

	local ret is get_stable_orbits_2(ship:body).

	circle(ret[0][0]).
}

print "loaded library circle".

