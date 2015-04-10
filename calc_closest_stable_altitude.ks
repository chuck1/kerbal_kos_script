


if ship:obt:hasnextpatch {
	print "ERROR: hasnextpatch is true".
	print neverset.
}

set get_stable_orbits_body to ship:body.
run get_stable_orbits.

if get_stable_orbits_ret:length = 1 {
	set so to get_stable_orbits_ret[0].
	
	set calc_closest_stable_altitude_ret to max(so[0], min(so[1], apoapsis)).
}



set i to 0.

until (i + 1) = get_stable_orbits_ret:length {
	set so1 to get_stable_orbits_ret[i].
	set so2 to get_stable_orbits_ret[i + 1].
	
	if apoapsis < (so1[0] * 1.1) {
		return (so1[0] * 1.1).
		break.
	}
	if apoapsis > (so1[0] * 1.1) and apoapsis < (so1[1] * 0.9) {
		// inside so1
		set calc_closest_stable_altitude_ret to apoapsis.
		break.
	} else if apoapsis > (so1[1] * 0.9) and apoapsis < (so2[0] * 1.1) {
		// between so1 and so2
		set calc_closest_stable_altitude_ret to (so1[1] * 0.9).
		break.
	}
	
	set i to i + 1.
}

if (i + 1) = get_stable_orbits_ret:length {
	set so to get_stable_orbits_ret[i].
	
	set calc_closest_stable_altitude_ret to (so[1] * 0.9).
}





