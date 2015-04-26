function ves_a_max {
	parameter ves.
	return ves:maxthrust / ves:mass.
}
function ves_burn_dur {
	parameter ves.
	parameter dv0.
	return abs(dv0) / ves_a_max(ves).
}
function ves_thrott_from_burn_dur {
	parameter ves.
	parameter dv0.
	return math_clamp(ves_burn_dur(ves,dv0) / 5, 0.01, 1).
}
function ves_thrott_from_a {
	parameter ves.
	parameter acc0.
	//print "ves_thrott_from_a " + ves + " " + acc0.
	return math_clamp(acc0 / ves_a_max(ves), 0, 1).
}
function ves_thrott_from_g {
	parameter ves.
	return math_clamp(ves_g(ves) / ves_a_max(ves), 0, 1).
}
function ves_g {
	parameter ves.
	return (ves:body:mu / ((ves:body:radius + ves:altitude)^2)).
}
function ves_twr {
	parameter ves.
	return ves_a_max(ves) / ves_g(ves).
}
function ves_normal {
	parameter ves.
	local vec is obt_h_for(ves).
	return vec:direction.
}
function ves_antinormal {
	parameter ves.
	local vec is -obt_h_for(ves).
	return vec:direction.
}
function ves_radialout {
	parameter ves.
	local vec is vcrs(obt_v_for(ves),obt_h_for(ves)).
	return vec:direction.
}
function ves_radialin {
	parameter ves.
	local vec is vcrs(obt_h_for(ves),obt_v_for(ves)).
	return vec:direction.
}
function ves_get_soe {
	parameter ves.
	return -1 * abs(ves:body:mu / 2 / ves:obt:semimajoraxis).
}
function ves_pitch_and_th_from_acc {
	// get pitch and throttle from...
	parameter ves.
	parameter acc_y. // scalar, desired vertical acceleration (up positive)
	parameter acc_x. // vector, desired surface acceleration
	parameter flag. 
	// flags
	// 0: priority is vertical
	// 1: priority is surface
	// 2: proportional (maintain ratio but scale to 1)
	
	// returns a vector whose magnitude should be used as throttle and
	// whose direction should be used for steering.

	local a_max is ves_a_max(ves).
	
	local th_x is acc_x / a_max.
	local th_y is acc_y / a_max.
	
	if sqrt(th_y^2 + vdot(th_x,th_x)) > 1 {
		// limited
		if flag = 0 { // y priority
			if th_y > 1 {
				// vertical throttle maxed out
				return up:vector.
			} else {
				set th_x to th_x:normalized * sqrt(1 - th_y^2).
			}
		} else if flag = 1 { // x priority
			if th_x:magnitude > 1 {
				// surface throttle maxed out
				return th_x:normalized.
			} else {
				set th_y to sqrt(1 - vdot(th_x,th_x)).
			}
		} else if flag = 2 {
			// proportional
			local th is up:vector * th_y + th_x.
			return th:normalized.
		} else {
			print neverset.
		}
	}
	return (up:vector * th_y + th_x).
}
function ves_th_from_cur_pitch_and_acc {
	// get throttle value basde on current pitch and desired vertical acceleration
	parameter ves.
	parameter acc_vert.
	
	local th_y is acc_vert / ves_a_max(ves).

	local pitch is 90 - vang(ves:facing:vector, up:vector).

	local th is th_y / sin(pitch).
	
	return math_clamp(th, 0, 1).
}




