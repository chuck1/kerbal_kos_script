
function get_stable_orbits {
	parameter b.
	
	//print "get_stable_orbits " + body.

	set ret to list().
	
	if b:atm:exists {
		set alt0 to b:atm:height.
	} else {
		set alt0 to get_highest_peak(b).
	}
	
	local ml is get_moons(b).
	
	local l is list().
	l:add(alt0).

	local m is 0.
	local i is 0.
	//for m in ml {
	until i = ml:length {
		set m to ml[i].
	
		local get_soi_ret to get_soi(m).
	
		l:add(m:periapsis - get_soi_ret).
		
		ret:add(l).
	
		set l to list().
		l:add(m:apoapsis + get_soi_ret).
		
		set i to i + 1.
	}
	
	l:add(get_soi(b)).
	
	ret:add(l).

	return ret.
}
function get_stable_orbits_2 {
	parameter body.

	//print "get_stable_orbits_2 " + body.

	// stable orbits with some room for error and extra room above body so that
	// low orbits dont have unstable apo/peri due to very low altitude
	
	local orbits is get_stable_orbits(body).
	
	set ret to list().
	
	// populate new list
	
	set get_stable_orbits_2_i to 0.
	
	until get_stable_orbits_2_i = orbits:length {
		set l to list().
	
		l:add(max(
			orbits[get_stable_orbits_2_i][0] * 1.1,
			body:radius * 3 / 40
			)).
		l:add(orbits[get_stable_orbits_2_i][1] * 0.9).
	
		ret:add(l).
	
		set get_stable_orbits_2_i to get_stable_orbits_2_i + 1.
	}
	return ret.
}	
function calc_obt_alt_low {
	parameter b.
	//print "calc_obt_alt_low " + b.
	local orbits is get_stable_orbits_2(b).
	return orbits[0][0].
}
function calc_obt_soe_circle {
	parameter b.
	parameter alt.
	
	//print "calc_obt_soe_circle " + b.

	local a is b:radius + alt.

	return (-1 * b:mu / (2 * a)).
}
function calc_obt_soe {
	parameter x.
	
	if 0 {
	print "calc_obt_soe " + x.
	}

	return (x:velocity:orbit:mag^2 / 2 - x:body:mu / (x:body:radius + x:altitude)).
}
function calc_obt_speed_at_altitude {
	parameter o.
	parameter altitude.
	return sqrt(2*(calc_obt_soe(o) + o:body:mu / (o:body:radius + altitude))).
}
function calc_obt_mean_motion {
	parameter x.
	
	local ot is calc_obt_type(x).
	local n is 0.
	
	if (ot = "elliptic") or (ot = "circular") {
	
		set n to 360 / x:obt:period.

	} else if (ot = "hyperbolic") {

		set n to sqrt(x:body:mu / ((-x:obt:semimajoraxis)^3)).
		
		set n to math_rad_to_deg(n).		

	} else {
		print neverset.
	}

	if 0 {
		print "calc_obt_mean_motion " + x.
		print "p " + x:obt:period.
		print "n " + n.	
	}

	return n.
}
function calc_obt_eccentric_anomaly {
	parameter x.

	local ta is x:obt:trueanomaly.
	local e is x:obt:eccentricity.
	
	local ot is calc_obt_type(x).
	
	local ea is 0.
	
	if (ot = "elliptic") or (ot = "circular") {
	
		set ea to arctan2(
			sqrt(1 - e^2) * sin(ta),
			e + cos(ta)).
	
	} else if (ot = "hyperbolic") {

		set ea to math_arccosh2(
			e + cos(ta),
			1 + e * cos(ta)).


	} else {
		print neverset.
	}
	
	set ea to math_clamp_angle(ea).
	
	if 0 {	
		print "calc_obt_eccentric_anomaly " + x.
		print "ta " + ta.
		print "e  " + e.
		print "ea " + ea.
	}

	return ea.
}
function calc_obt_mean_anomaly {
	parameter x.
	
	local ea is calc_obt_eccentric_anomaly(x).
	local e is x:obt:eccentricity.

	if 0 {
	print "calc_obt_mean_anomaly " + x.
	print "ea " + ea.
	print "e  " + e.
	}

	local ma is 0.
	local ot is calc_obt_type(x).

	if (ot = "elliptic") or (ot = "circular") {

		set ma to ea - e * (180 / constant():pi) * sin(ea).

	} else if (ot = "hyperbolic") {

		set ma to e * (180 / constant():pi) * math_sinh(ea) - ea.

		set ma to 360 - ma.
	}

	return ma.
}
function calc_obt_time_to_periapsis {
	parameter x.


	local n is calc_obt_mean_motion(x).

	
	local m0 is calc_obt_mean_anomaly(x).
	local m1 is 360.
	
	local t is (m1 - m0) / n.

	if 0 {
	print "calc_obt_time_to_periapsis " + x.
	print "m0 "  + m0.
	print "m1 "  + m1.
	print "n  "  + n.
	print "eta " + t.
	}

	return t.
}
function calc_obt_time_to_apoapsis {
	parameter x.
	
	//print "calc_obt_time_to_apoapsis " + x.

	local m0 is calc_obt_mean_anomaly(x).
	local m1 is 180.
	
	return math_clamp_angle(m1 - m0) / calc_obt_mean_motion(x).
}
function calc_obt_a_from_period {
	parameter x.
	parameter p.
	
	return (x:body:mu * (p / 2 / constant():pi)^2)^(1/3).
}
function calc_obt_per_from_apo_and_period {
	parameter x.
	parameter apo.
	parameter p.
	
	local a is calc_obt_a_from_period(x,p).
	
	local per is 2 * a - apo.
	
	return per.
}
function calc_obt_apo_from_per_and_period {
	parameter x.
	parameter per.
	parameter p.
	
	local a is calc_obt_a_from_period(x,p).
	
	local apo is 2 * a - per.
	
	return apo.
}
function calc_obt_pres {
	parameter x.

	local scale is x:body:atm:scale * 1000.
	
	local pres0 is x:body:atm:sealevelpressure * ( constant():e ^ ( -1 * x:altitude / scale ) ).
	
	return pres0.
}
function calc_obt_term_speed {
	parameter x.
	
	local ship_k to 0.02.
	
	local pres0 is calc_obt_pres(x).
	
	//lock term_speed to ship:termvelocity / term_speed_scale).
	local term_speed0 is sqrt(2 * x:mass * g / pres0 / ship_k).
	
	return term_speed0.
}
function calc_distance_to_target {
	set t to time.
	
	set t1 to time + eta:apoapsis.
	
	set ps1 to positionat(ship,   t1).
	set pt1 to positionat(target, t1).
	
	set d1 to (pt1 - ps1):mag.
	
	print "distance at ship apoapsis " + d1.
}
function calc_closest_stable_altitude {
	
	if ship:obt:hasnextpatch {
		set altitude_of_interest to periapsis.
	} else {
		set altitude_of_interest to apoapsis.
	}
	
	local orbits is get_stable_orbits_2(ship:body).
	
	
	if orbits:length = 1 {
	
		set so to orbits[0].
		
		set calc_closest_stable_altitude_ret to
			max(
				so[0],
				min(
					so[1],
					altitude_of_interest)).
	} else {
		set i to 0.
	
		until (i + 1) = orbits:length {
			set so1 to orbits[i].
			set so2 to orbits[i + 1].
		
			if altitude_of_interest < so1[0] {
				return so1[0].
			} else if
					altitude_of_interest > so1[0] and
					altitude_of_interest < so1[1] {
				// inside so1
				return altitude_of_interest.
			} else if
					altitude_of_interest > so1[1] and
					altitude_of_interest < so2[0] {
				// between so1 and so2
				return so1[1].
			}
		
			set i to i + 1.
		}
	
		if (i + 1) = orbits:length {
			return orbits[i][1].
		}
	
	}
	return 0.
}

print "loaded library calc_obt".

