
function circle {
	parameter circle_altitude.
	parameter is_boot_func.

	print "circle " + circle_altitude.

	local obt_type is calc_obt_type(ship).

	if (obt_type = "landed") or (obt_type = "prelaunch") {
		launch(circle_altitude).
		return 1.
	}

	sas off.
	rcs off.
	set warp to 0.
	
	
	if circle_altitude = 0 {
		run calc_closest_stable_altitude.
		set circle_altitude to calc_closest_stable_altitude_ret.
	}
	
	util_log("circle " + circle_altitude).
	
	set precision to 0.2.
	
	//set mvr_adjustcle_precision
	
	lock error_max to max(
		abs((apoapsis  - circle_altitude)/circle_altitude),
		abs((periapsis - circle_altitude)/circle_altitude)).
	
	if ship:obt:hasnextpatch {
		run capture(circle_altitude).
	}
	
	set mvr_adjust_altitude to circle_altitude.
	
	set circle_error_apoapsis  to abs((apoapsis  - circle_altitude) / (ship:obt:semimajoraxis)).
	set circle_error_periapsis to abs((periapsis - circle_altitude) / (ship:obt:semimajoraxis)).
	
	set circle_ret to 1.
	
	//until error_max < precision {
	if		(ship:obt:eccentricity < 0.05) and
			(circle_error_apoapsis < 0.05) and
			(circle_error_periapsis < 0.1) {
		print "orbit is circular".
		return 0.
	} else {
		
		run mvr_safe_periapsis.
		
		print "eta:apoapsis  " + eta:apoapsis.
		print "eta:periapsis " + eta:periapsis.
		
		if ship:verticalspeed > 0 {
			
			if (circle_error_periapsis < 0.05) {
				run mvr_adjust_at_periapsis.
			} else {
				run mvr_adjust_at_apoapsis.
			}
			
		} else if ship:verticalspeed < 0 {
	
			if (circle_error_apoapsis < 0.05) {
				run mvr_adjust_at_apoapsis.
			} else {
				run mvr_adjust_at_periapsis.
			}
	
		}
		
	}
	return 1.
}
function circle_low {
	util_log("circle_low").

	local ret is get_stable_orbits_2(ship:body).

	circle(ret[0][0]).
}

print "loaded library circle".

