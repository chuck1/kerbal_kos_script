clearscreen.
print "rendezvous approach".

// ==========================================

lock o_target to target:position - ship:position.

lock o to o_target.

lock v to ship:velocity:orbit - target:velocity:orbit.

// positive indicates moving toward target
lock d to vdot(o,v).

// velocity component perpendicular to position vector
lock v_perp to vectorexclude(v,o).

lock accel_max to ship:maxthrust / ship:mass.

// set v

// goal is to reach target in 60 seconds
lock v0 to o / 60.

lock v_burn to v0 - v.

lock burn_time_max to v_burn:mag / accel_max.

// desired accel is accel needed for 1 second burn
lock accel to v_burn:mag / 1.

lock th0 to accel / accel_max.


lock steering to v_burn:direction.

// make sure steering keeps up
when vang(steering:vector, ship:facing:vector) > 2 then {
	lock throttle to 0.
	preserve.
}
when vang(steering:vector, ship:facing:vector) < 2 then {
	lock throttle to th.
	preserve.
}

until o:mag < 2500 {

	// wait until significant burn is needed
	wait until (v_burn:mag / v:mag) > 0.1. 

	// burn
	until v_burn:mag < 0.1 or o:mag < 2500 {
		set th to max(0.01, min(1, th0)).
		lock throttle to th.
	}

	lock throttle to 0.
	set th to 0.

	print o:mag.

	wait 0.1.
}	




