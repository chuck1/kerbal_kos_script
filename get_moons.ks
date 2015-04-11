// PARAM get_moons_body

set get_moons_ret to list().

if get_moons_body = kerbin {
	get_moons_ret:add(mun).
	get_moons_ret:add(minmus).
} else if get_moons_body = duna {
	get_moons_ret:add(ike).
}

unset get_moons_body.


