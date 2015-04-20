
if ship:obt:hasnextpatch {
	set altitude_of_interest to periapsis.
} else {
	set altitude_of_interest to apoapsis.
}

local orbits is get_stable_orbits_2(ship:body).

for l in get_stable_orbits_ret {
	//print l.
}

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

	until (i + 1) = get_stable_orbits_ret:length {
		set so1 to orbits[i].
		set so2 to orbits[i + 1].
	
		if altitude_of_interest < so1[0] {
			set calc_closest_stable_altitude_ret to so1[0].
			break.
		} else if
		altitude_of_interest > so1[0] and
		altitude_of_interest < so1[1] {
			// inside so1
			set calc_closest_stable_altitude_ret to altitude_of_interest.
			break.
		} else if
		altitude_of_interest > so1[1] and
		altitude_of_interest < so2[0] {
			// between so1 and so2
			set calc_closest_stable_altitude_ret to so1[1].
			break.
		}
	
		set i to i + 1.
	}

	if (i + 1) = orbits:length {
		set calc_closest_stable_altitude_ret to
			orbits[i][1] * 0.9.
	}

}


