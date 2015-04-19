
declare parameter calc_burn_duration_dv.

run calc_stage_deltav.

set calc_burn_duration_ret to 0.

set calc_burn_duration_i to (ship_stage_count - 1).
until calc_burn_duration_i < 0 {
	if calc_burn_duration_dv > ship_stage_deltav[calc_burn_duration_i] {
		set calc_burn_duration_ret to
			calc_burn_duration_ret +
			ship_stage_duration_max[calc_burn_duration_i].

		set calc_burn_duration_dv to
			calc_burn_duration_dv -
			ship_stage_deltav[calc_burn_duration_i].
	} else {
		set calc_burn_duration_ret to
			calc_burn_duration_ret +
			ship_stage_duration_max[calc_burn_duration_i] *
			calc_burn_duration_dv /
			ship_stage_deltav[calc_burn_duration_i].
	
		set calc_burn_duration_dv to 0.

		break.
	}

	set calc_burn_duration_i to calc_burn_duration_i - 1.
}

if calc_burn_duration_dv > 0 {
	print "insufficient deltav".
	//print neverset.
}







