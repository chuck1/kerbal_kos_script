
print "CALC CLOSEST STABLE ALTITUDE".

if ship:obt:hasnextpatch {
	set altitude_of_interest to periapsis.
} else {
	print "consider apoapsis".
	set altitude_of_interest to apoapsis.
}

set get_stable_orbits_body to ship:body.
run get_stable_orbits.

for l in get_stable_orbits_ret {
	print l.
}

if get_stable_orbits_ret:length = 1 {

	set so to get_stable_orbits_ret[0].
	
	set calc_closest_stable_altitude_ret to max(so[0] * 1.1, min(so[1] * 0.9, altitude_of_interest)).
} else {



	set i to 0.

	until (i + 1) = get_stable_orbits_ret:length {
		set so1 to get_stable_orbits_ret[i].
		set so2 to get_stable_orbits_ret[i + 1].
	
		if ship:obt:hasnextpatch < (so1[0] * 1.1) {
			return (so1[0] * 1.1).
			break.
		}
		if ship:obt:hasnextpatch > (so1[0] * 1.1) and ship:obt:hasnextpatch < (so1[1] * 0.9) {
			// inside so1
			set calc_closest_stable_altitude_ret to ship:obt:hasnextpatch.
			break.
		} else if ship:obt:hasnextpatch > (so1[1] * 0.9) and ship:obt:hasnextpatch < (so2[0] * 1.1) {
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

}

print "return " + calc_closest_stable_altitude_ret.

wait 3.

