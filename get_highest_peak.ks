// PARAM get_body_info_body

if get_body_info_body = kerbin {
	set ml to list().
	ml:add(mun).
	ml:add(minmus).

	set body_info to list().
	body_info:add(    6767). // highest peak
	body_info:add(ml).       // moons
	
} else if get_body_info_body = mun {
	set body_info to list().
	body_info:add(7061).
	body_info:add(0).
} else if get_body_info_body = duna8264

// min stable orbit

if get_body_info_body:atm:exists {
	body_info:add(get_body_info_body:atm:height).
} else {
	body_info:add(body_info[0]).
}

// stable orbits (avoid natural satellites)

set l to list().
l:add(body_info[3]).

for m in body_info[2] {
	l:add(m:preiapsis - 
}










unset get_body_info_body.


