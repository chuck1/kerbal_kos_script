// warp an AMOUNT of time
declare parameter warp_time_tspan.

print "warp_time " + warp_time_tspan.

local t0 is TIME:seconds.

local warp_time_eta is 0.

set t to 1.

set warp_limit to 7.

if ship:body:atm:exists and ship:altitude < ship:body:atm:height {
} else {
	until 0 {
	
		set warp_time_eta to (warp_time_tspan - (time:seconds - t0)).

		if warp_time_eta < 1 {
			break.
		}

		if warp_time_eta > 100000 * t and warp_limit > 6 {
			set warp to 7.
		} else if warp_time_eta > 10000 * t {
			set warp to 6.
		} else if warp_time_eta > 1000 * t {
			set warp to 5.
		} else if warp_time_eta > 100 * t {
			set warp to 4.	
		} else if warp_time_eta > 50 * t {
			set warp to 3.	
		} else if warp_time_eta > 10 * t {
			set warp to 2.
		} else if warp_time_eta > (5 * t) {
			set warp to 1.
		}

		clearscreen.
		print "WARP TIME".
		print "===================".
		print "    warp " + warp.
		print "    eta  " + warp_time_eta.
		print "    time " + warp_time_tspan.
	}

}

set warp to 0.


