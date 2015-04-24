function warp_time {
	// warp an AMOUNT of time
	declare parameter warp_time_tspan.
	
	print "warp_time " + warp_time_tspan.
	
	local t0 is TIME:seconds.
	
	local warp_time_eta is 0.
	
	set t to 1.
	
	set warp_limit to 6.
	
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
	
			if 0 {
			clearscreen.
			print "WARP TIME".
			print "===================".
			print "    warp " + warp.
			print "    eta  " + warp_time_eta.
			print "    time " + warp_time_tspan.
			}
		}
	
	}
	
	set warp to 0.
}
function warp_to {
	parameter warp_string.
	parameter warp_sub.
	
	print "warp_to " + warp_string.

	declare local warp_eta to 0.
	
	if warp_string = "apo" {
		lock warp_eta to eta:apoapsis - warp_sub.
	} else if warp_string = "per" {
		lock warp_eta to eta:periapsis - warp_sub.
	} else if warp_string = "node" {
		set n to nextnode.
		lock warp_eta to n:eta - warp_sub.
	} else if warp_string = "trans" {
		lock warp_eta to eta:transition - warp_sub.
	} else {
		print "ERROR".
		print neverset.
	}
	
	set warp_limit to 6.
	
	set warp_t to 1.
	
	if ship:body:atm:exists and ship:altitude < ship:body:atm:height {
	} else {
	
		until warp_eta < 1 {
			if warp_eta > 100000 * warp_t and warp_limit > 6 {
				set warp to 7.
			} else if warp_eta > 10000 * warp_t {
				set warp to 6.
			} else if warp_eta > 1000 * warp_t {
				set warp to 5.
			} else if warp_eta > 100 * warp_t {
				set warp to 4.	
			} else if warp_eta > 50 * warp_t {
				set warp to 3.	
			} else if warp_eta > 10 * warp_t {
				set warp to 2.
			} else if warp_eta > (5 * warp_t) {
				set warp to 1.
			}
	
			if 0 {
			clearscreen.
			print "WARP".
			print "===================".
			print "    mode " + warp_string.
			print "    warp " + warp.
			print "    eta  " + warp_eta.
			}
	
			wait 0.1.
		}
	
	}
	set warp to 0.
	//cleanup
	unlock warp_eta.
	unset warp_eta.
}	
function warp_per {
	parameter warp_sub.
	warp_to("per", warp_sub).
}
function warp_apo {
	parameter warp_sub.
	warp_to("apo", warp_sub).
}
function warp_trans {
	parameter warp_sub.
	warp_to("trans", warp_sub).
}
