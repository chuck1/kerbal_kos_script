//declare parameter warp_string.
//declare parameter warp_sub.



if warp_string = "apo" {
	lock e to eta:apoapsis - warp_sub.
} else if warp_string = "per" {
	lock e to eta:periapsis - warp_sub.
} else if warp_string = "node" {
	set n to nextnode.
	lock e to n:eta - warp_sub.
} else if warp_string = "trans" {
	lock e to eta:transition - warp_sub.
} else {
	print "ERROR".
	print neverset.
}

set warp_limit to 7.

set warp_t to 1.

if ship:body:atm:exists and ship:altitude < ship:body:atm:height {
} else {

	until e < 1 {
		if e > 100000 * t and warp_limit > 6 {
			set warp to 7.
		} else if e > 10000 * warp_t {
			set warp to 6.
		} else if e > 1000 * warp_t {
			set warp to 5.
		} else if e > 100 * warp_t {
			set warp to 4.	
		} else if e > 50 * warp_t {
			set warp to 3.	
		} else if e > 10 * warp_t {
			set warp to 2.
		} else if e > (5 * warp_t) {
			set warp to 1.
		}

		clearscreen.
		print "WARP".
		print "===================".
		print "    mode " + warp_string.
		print "    warp " + warp.
		print "    eta  " + e.
	}

}


set warp to 0.

unset warp_string.
unset warp_sub.







