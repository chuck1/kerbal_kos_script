function calc_burn_duration {
	parameter dv.
	
	run calc_stage_deltav.
	
	local ret is 0.
	
	local i is (ship_stage_count - 1).

	until i < 0 {
		if dv > ship_stage_deltav[i] {
			set ret to ret +
				ship_stage_duration_max[i].
	
			set dv to dv - ship_stage_deltav[i].
		} else {
			set ret to ret +
				ship_stage_duration_max[i] *
				dv / ship_stage_deltav[i].
		
			set dv to 0.
	
			break.
		}
	
		set i to i - 1.
	}
	
	if dv > 0 {
		print "insufficient deltav".
		//print neverset.
	}
	
	return ret.
}


function calc_deltav {
	parameter deltav_alt.
	parameter deltav_alt1.
	parameter deltav_alt2.
	
	local debug is true.
	
	// alt is the burn altitude / common altitude
	
	// orbit radius
	local r  is deltav_alt  + ship:body:radius.
	local r1 is deltav_alt1 + ship:body:radius.
	local r2 is deltav_alt2 + ship:body:radius.
	
	// semi-major
	local deltav_a1 is (r + r1) / 2.
	local deltav_a2 is (r + r2) / 2.
	
	local v1 is sqrt(ship:body:mu * (2/r - 1/deltav_a1)).
	local v2 is sqrt(ship:body:mu * (2/r - 1/deltav_a2)).

	local dv is v2 - v1.

	if debug {
	print "calculate dv".
	print "alt  " + deltav_alt.
	print "alt1 " + deltav_alt1.
	print "alt2 " + deltav_alt2.
	print "r    " + r.
	print "r1   " + r1.
	print "r2   " + r2.
	print "a1   " + deltav_a1.
	print "a2   " + deltav_a2.
	print "v1   " + v1.
	print "v2   " + v2.
	print "dv   " + dv.
	}

	
	return dv.
	
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

