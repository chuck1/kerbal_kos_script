// PARAM get_stable_orbits_body

set get_stable_orbits_ret to list().

if get_stable_orbits_body:atm:exists {
	set alt0 to get_stable_orbits_body:atm:height.
} else {
	set get_highest_peak_body to get_stable_orbits_body.
	run get_highest_peak.
	
	set alt0 to get_highest_peak_ret.
}

set get_moons_body to get_stable_orbits_body.
run get_moons.

set l to list().
l:add(alt0).

for m in get_moons_ret {

	set get_soi_body to m.
	run get_soi.

	l:add(m:periapsis - get_soi_ret).
	
	get_stable_orbits_ret:add(l).

	set l to list().
	l:add(m:apoapsis + get_soi_ret).
}

set get_soi_body to get_stable_orbits_body.
run get_soi.

l:add(get_soi_ret).

get_stable_orbits_ret:add(l).

//print "so".
//for o in so {
//	print o.
//}



unset get_stable_orbits_body.


