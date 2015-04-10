
// PARAMETER go_to_dest.

run global_var.
run get_body_info.

set calc_latlong_to_vector_dest to go_to_dest.
set calc_latlong_to_vector_alt  to body_info[0].
run calc_latlong_to_vector.



until 0 {
	run calc_latlong_to_vector.

	if calc_latlong_to_vector_distance < 15000 {
		break.
	}

	set hop_mode to "latlong".
	set hop_dest to mun_arch.
	run hop.
}


set hover_alt_mode to "asl".
set hover_hor_mode to "latlong".
set hover_alt      to mun_arch[2].
set hover_dest     to mun_arch.
run hover.

run power_land_final.


