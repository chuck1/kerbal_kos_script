// PARAM get_moons_body

if get_moons_body = kerbin {
	set get_moons_ret to list().
	get_moons_ret:add(mun).
	get_moons_ret:add(minmus).
} else if get_moons_body = duna {
	set get_moons_ret to list().
	get_moons_ret:add(ike).
}

unset get_moons_body.


