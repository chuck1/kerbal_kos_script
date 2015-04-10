// PARAM get_capture_alt_body

set get_aerobrake_alt_body to get_capture_alt_body.
run get_aerobrake_alt.

if get_aerobrake_alt_ret = 0 {
	set get_stable_orbits_body to get_capture_alt_body.
	run get_stable_orbits.
	
	set so to get_stable_orbits_ret[get_stable_orbits_ret:length - 1].
	set get_capture_alt_ret to (so[1] * 0.9).
} else {
	set get_capture_alt_ret to get_aerobrake_alt_ret.
}

unset get_capture_alt_body.


