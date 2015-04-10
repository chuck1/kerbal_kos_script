
if not (ship:body:atm:exists) {
	print neverset.
}
if not (periapsis < ship:body:atm:height) {
	print neverset.
}
if ship:verticalspeed > 0 {
	print neverset.
}

lock e to (altitude - ship:body:atm:height) / ship:verticalspeed.

set warp_t to 1.

print "warp to atm".

if ship:body:atm:exists and ship:altitude < ship:body:atm:height {
} else {
	if e > 100000 * warp_t {
		set warp to 7.
		wait until e < 100000 * warp_t.
		set warp to 6.
	}
	if e > 10000 * warp_t {
		set warp to 6.	
		wait until e < 10000 * warp_t.
		set warp to 5.
	}
	if e > 1000 * warp_t {
		set warp to 5.
		wait until e < 1000 * warp_t.
		set warp to 4.
	}
	if e > 100 * warp_t {
		set warp to 4.	
		wait until e < 100 * warp_t.
		set warp to 3.
	}
	if e > 50 * warp_t {
		set warp to 3.	
		wait until e < 50 * warp_t.
		set warp to 2.
	}
	if e > 10 * warp_t {
		set warp to 2.
		wait until e < 10 * warp_t.
		set warp to 1.
	}
	if e > 5 * warp_t {
		set warp to 1.
		wait until e < 5 * warp_t.
		set warp to 0.
	}
}

set warp to 0.

print "wait until ship hits the atm".
wait until (altitude - ship:body:atm:height).
print "ship has hit the atm".









