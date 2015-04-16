// PARAM get_stable_orbits_2_body

// stable orbits with some room for error and extra room above body so that
// low orbits dont have unstable apo/peri due to very low altitude

set get_stable_orbits_body to get_stable_orbits_2_body.
run get_stable_orbits.

set get_stable_orbits_2_ret to list().

// populate new list

set get_stable_orbits_2_i to 0.

until get_stable_orbits_2_i = get_stable_orbits_ret:length {
	set l to list().

	l:add(max(
		get_stable_orbits_ret[get_stable_orbits_2_i][0] * 1.1,
		get_stable_orbits_2_body:radius * 3 / 40
		)).
	l:add(get_stable_orbits_ret[get_stable_orbits_2_i][1] * 0.9).

	get_stable_orbits_2_ret:add(l).

	set get_stable_orbits_2_i to get_stable_orbits_2_i + 1.
}

// cleanup
unset get_stable_orbits_2_body.



