rcs on.

set warp_string to "node".
set warp_sub    to 60.
run warp.

set warp to 0.

set n to nextnode.


lock steering to R(
	n:deltav:direction:pitch,
	n:deltav:direction:yaw,
	ship:facing:roll).
run wait_orient.

if wait_orient_ret > 0 {
	print "ignoring node".
	wait 5.
} else {

	lock accel_max to ship:maxthrust / ship:mass.

	lock est_rem_burn to n:deltav:mag / accel_max.

	set th to 0.
	lock throttle to th.

	set dv_min to n:deltav:mag.

	until n:deltav:mag < 0.01 {

		set th to max(0, min(1, est_rem_burn / 10 + 0.01)).
	
		set dv_min to min(dv_min, n:deltav:mag).	

		clearscreen.
		print "BURN".
		print "====================================".
		print "    dv     " + n:deltav:mag.
		print "    dv min " + dv_min.
		print "    eta    " + est_rem_burn.
	
		if vang(ship:facing:vector, steering:vector) > 1 {
			lock throttle to 0.
			print "reorienting".
		} else {
			lock throttle to th.
		}

		if n:deltav:mag > (dv_min + 0.01) {
			print "ERROR dv increasing".
			lock throttle to 0.
			wait 3.
			break.
		}
	}

	lock throttle to 0.
	wait 5.


	until n:deltav:mag < 0.01 {

		clearscreen.
		print "BURN".
		print "====================================".
		print "    dv     " + n:deltav:mag.
		print "    dv min " + dv_min.
		print "rcs mode".
		
		set ship:control:translation to (ship:facing:inverse * n:deltav:normalized).
		
		if n:deltav:mag > (dv_min + 0.01) {
			print "ERROR dv increasing".
			wait 3.
			break.
		}
	}

	set ship:control:translation to V(0,0,0).

	print "node burn complete".

	
	wait 4.
}

unlock steering.

remove n.



