// PARAM get_aerobrake_alt_body

if get_aerobrake_alt_body = kerbin {
	set get_aerobrake_alt_ret to 35000.
} else if get_aerobrake_alt_body = duna {
	set get_aerobrake_alt_ret to 13000.
} else {
	set get_aerobrake_alt_ret to 0.
}

unset get_aerobrake_alt_body.


