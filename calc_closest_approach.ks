declare parameter calc_closest_approach_dest.


set  t_l to time:seconds.
lock p_l to positionat(ship, t_l).
lock r_l to p_l - ship:body:position.

lock alt_l to r_l:mag - ship:body:radius.

// horizontal distance to latlng at t_l
lock d_l to vxcl(r_l, p_l - calc_closest_approach_dest[0]:position).


set t_l to time:seconds.

until 0 {
	set calc_closest_approach_ret to d_l:mag.

	if alt_l < (calc_closest_approach_dest[1] + 1000) {
		break.
	}

	set t_l to t_l + 1.
}





