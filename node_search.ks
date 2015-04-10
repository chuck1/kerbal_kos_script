// PARAM node_search_alt
// PARAM node_search_use_normal
// PARAM node_search_target

// eliminate instability in orbit
set warp to 1.

set get_soi_body to node_search_target.
run get_soi.

set target_soi to get_soi_ret.

set t to time.

set t_closest to time + eta:apoapsis.

// create node
set n to node(time:seconds + 7200, 0, 0, 0).

add n.

set dist_error     to 1000000000000.
set dist_error_min to dist_error.

lock node_altitude_r to node_search_target:radius + node_search_alt.


lock dist_error_percent to dist_error / node_search_alt.



set dist_thresh to 100.

set  count to 0.
set count2 to 0.
set      i to 0.
set     dv to 10.
set     dt to eta:apoapsis / 100.


set closer to false.

set node_search_abort to 0.
on ag1 {
	set node_search_abort to 1.
}

set obt_string to "".

until node_search_abort = 1 {
	clearscreen.
	print "NODE SEARCH".
	print "===============================".
	if n:orbit:body = node_search_target {
	print "peri         " + n:orbit:periapsis.
	}
	print "target alt   " + node_search_alt.
	print "dist error   " + dist_error.
	print "dist error % " + dist_error_percent.
	print "t_closest    " + t_closest.
	print "n:eta        " + n:eta.
	print "n:deltav     " + n:deltav:mag.
	print "i            " + i.
	print "count        " + count.
	print "count2       " + count2.
	print "dv           " + dv.
	print "dt           " + dt.
	print "use normal   " + node_search_use_normal.
	print "orbit desc   " + obt_string.


	if i = 0 {
		set t_closest to t_closest + dt.
	} else if i = 1 {
		set t_closest to t_closest - dt.
	} else if i = 2 {
		set n:prograde to n:prograde + dv.
	} else if i = 3 {
		set n:prograde to n:prograde - dv.
	} else if i = 4 {
		set n:radialout to n:radialout + dv.
	} else if i = 5 {
		set n:radialout to n:radialout - dv.
	} else if i = 6 and node_search_use_normal {
		set n:normal to n:normal + dv.
	} else if i = 7 and node_search_use_normal {
		set n:normal to n:normal - dv.
	}

	// =============================================
	// evaluate error
	// cannot use lock because nature of orbit might change

	if ship:body = node_search_target {

		set dist_error to abs(n:orbit:periapsis - node_search_alt).
		
		set obt_string to "orbiting target body".
	} else if n:orbit:body = node_search_target {
		set dist_error to abs(n:orbit:periapsis - node_search_alt).
		
		set obt_string to "at node, orbiting target body".
	} else if n:orbit:hasnextpatch {

		set dist_error to abs(n:orbit:nextpatch:periapsis - node_search_alt).

		set obt_string to "nextpatch is orbiting target body".
	} else {
		// far away and no reliable encounter
		set ps to positionat(ship,   t_closest).
		set pt to positionat(target, t_closest).

		set dist to (pt - ps):mag.

		set dist_error to abs(dist - node_altitude_r).

		set obt_string to "no encounter".
	}


	// =============================================
	// respond to error
	// by using the minimum dist_error recorded, instabilities
	// will not result in false-possitive reductions in dist_error
	// this should cause program to exit sooner when instability is present

	if dist_error < (dist_error_min - dist_thresh) {
		set closer to true.
		set count2 to count2 + 1.
	} else {
		// reverse change
		if i = 0 {
			set t_closest to t_closest - dt.
		} else if i = 1 {
			set t_closest to t_closest + dt.
		} else if i = 2 {
			set n:prograde to n:prograde - dv.
		} else if i = 3 {
			set n:prograde to n:prograde + dv.
		} else if i = 4 {
			set n:radialout to n:radialout - dv.
		} else if i = 5 {
			set n:radialout to n:radialout + dv.
		} else if i = 6 and node_search_use_normal {
			set n:normal to n:normal - dv.
		} else if i = 7 and node_search_use_normal {
			set n:normal to n:normal + dv.
		}
		
		set i to i + 1.
		if i = 8 {
			set i to 0.
			
			if not closer {
				set count to count + 1.
				if dist_error_percent < 0.01 {
					break.
				}
				if count = 10 {
					break.
				}
				
				set dv to dv * 0.5.
				set dt to dt * 0.5.
			}

			set closer to false.
		}
	}

	set dist_error_min to min(dist_error, dist_error_min).

	wait 0.05.
}

set node_search_error to dist_error_percent.

unset node_search_use_normal.
unset node_search_alt.
unset node_search_target.

set warp to 0.



