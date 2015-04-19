function calc_burn_duration {
	parameter dv.
	
	run calc_stage_deltav.
	
	declare local ret to 0.
	
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
	
	return ret.
}





function calc_deltav {
	parameter deltav_alt.
	parameter deltav_alt1.
	parameter deltav_alt2.
	
	declare local debug is 0.
	
	// alt is the burn altitude / common altitude
	
	// orbit radius
	declare local deltav_r  is deltav_alt  + ship:body:radius.
	declare local deltav_r1 is deltav_alt1 + ship:body:radius.
	declare local deltav_r2 is deltav_alt2 + ship:body:radius.
	
	// semi-major
	declare local deltav_a1 is (deltav_r + deltav_r1) / 2.
	declare local deltav_a2 is (deltav_r + deltav_r2) / 2.
	
	if debug {
	//print "calculate dv".
	//print "alt  " + deltav_alt.
	//print "alt1 " + deltav_alt1.
	//print "alt2 " + deltav_alt2.
	//print "r    " + deltav_r.
	//print "r1   " + deltav_r1.
	//print "r2   " + deltav_r2.
	//print "a1   " + deltav_a1.
	//print "a2   " + deltav_a2.
	}
	
	return (sqrt(ship:body:mu * (2/deltav_r - 1/deltav_a2))
		- sqrt(ship:body:mu * (2/deltav_r - 1/deltav_a1))).
	
}

function calc_closest_approach {
	parameter dest.
	
	declare local p_l   is V(0,0,0).
	declare local r_l   is V(0,0,0).
	declare local d_l   is V(0,0,0).
	declare local alt_l is 0.
	
	declare local t_l is time:seconds.

	declare local d_l_min is 0.

	until 0 {

		set p_l to positionat(ship, t_l).
		set r_l to p_l - ship:body:position.
	
		set alt_l to r_l:mag - ship:body:radius.
	
		// horizontal distance to latlng at t_l
		set d_l to vxcl(r_l, p_l - dest[0]:position).

		if alt_l < (dest[1] + 1000) {
			break.
		}
	
		set t_l to t_l + 1.
	}

	return d_l:mag.
}

print "loaded library calculate".

