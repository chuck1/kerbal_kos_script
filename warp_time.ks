// warp an AMOUNT of time


set t0 to TIME:seconds.

lock e to (warp_time_tspan - (time:seconds - t0)).

set t to 1.

set warp_limit to 7.

if ship:body:atm:exists and ship:altitude < ship:body:atm:height {
} else {
	until e < 1 {
		if e > 100000 * t and warp_limit > 6 {
			set warp to 7.
		} else if e > 10000 * t {
			set warp to 6.
		} else if e > 1000 * t {
			set warp to 5.
		} else if e > 100 * t {
			set warp to 4.	
		} else if e > 50 * t {
			set warp to 3.	
		} else if e > 10 * t {
			set warp to 2.
		} else if e > (5 * t) {
			set warp to 1.
		}

		clearscreen.
		print "WARP TIME".
		print "===================".
		print "    warp " + warp.
		print "    eta  " + e.
		print "    time " + warp_time_tspan.
	}

}

unset warp_time_tspan.

