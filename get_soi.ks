// PARAM get_soi_body

if get_soi_body = kerbin {
	set get_soi_ret to 84159286.
} else if get_soi_body = mun {
	set get_soi_ret to  2429559.1.
} else if get_soi_body = minmus {
	set get_soi_ret to  2247428.4.
} else if get_soi_body = duna {
	set get_soi_ret to 47921949.
} else if get_soi_body = ike {
	set get_soi_ret to  1049598.9.
} else {
	print "no data for " + get_soi_body.
	print neverset.
}

unset get_soi_body.


