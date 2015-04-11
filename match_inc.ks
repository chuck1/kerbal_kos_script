sas off.
rcs on.
set warp to 0.
lock throttle to 0.

print "MATCH INCLINATION -------------------------------".
print "    body = " + match_inc_target.

// =======================================================================
// variables

lock accel_max to ship:maxthrust / ship:mass.

// assumes roughly circular orbit
//lock ang_speed to 360 / ship:obt:period.

lock h to vcrs(
	ship:position - ship:body:position,
	ship:velocity:orbit - ship:body:velocity:orbit).


lock h_target to vcrs(
	ship:body:position       - match_inc_target:position,
	ship:body:velocity:orbit - match_inc_target:velocity:orbit).

//print "h        " + h.
//print "h_target " + h_target.

lock v_c to vcrs(h_target, h).

lock v_p to ship:position - ship:body:position.

lock v_c0 to v_c.
lock v_c1 to -1 * v_c.

//print "v_c  " + v_c.
//print "v_p  " + v_p.
//print "v_c0 " + v_c0.
//print "v_c1 " + v_c1.



lock ang0 to
	vang(v_p, v_c0) *
	vdot(vcrs(v_p, v_c0), h) / 
	abs(vdot(vcrs(v_p, v_c0), h)).

lock ang1 to
	vang(v_p, v_c1) *
	vdot(vcrs(v_p, v_c1), h) /
	abs(vdot(vcrs(v_p, v_c1), h)).


lock ang_inc to min(
	vang(h_target, h),
	vang(-1 * h_target, h)).

print "plane inclination difference: " + ang_inc.
set ang_inc_start to ang_inc.

lock vs to (ship:velocity:orbit - ship:body:velocity:orbit):mag.

lock dv to 2 * vs * sin(ang_inc / 2).

lock est_rem_burn to (dv / accel_max).

until ang_inc < 0.1 {

	print "wait for node".
	
	if vdot(ship:velocity:orbit, v_c0) < 0 {
		print "heading to ascending".
		lock ang to ang1.
	} else {
		print "heading to descending".
		lock ang to ang0.
	}

	wait 2.
	set warp to 1.
	wait 2.

	set warp_time_tspan to (ang / (360 - ship:obt:trueanomaly) * eta:periapsis - 30).
	run warp_time.

	until abs(ang) < 5 {
		//run time_at_closest(v_c).
		//print "eta to closest " + (time - t):clock.
		//print ang + " " + ang_inc.
		print "angle to burn " + round(ang,1) + " ta " + round(ship:obt:trueanomaly,1).
		wait 1.
	}

	set warp to 0.
	wait 2.

	if vdot(-1 * ship:body:position, v_c) > 0 {		
		lock steering to (-1 * h):direction.
	} else {
		lock steering to h:direction.
	}
	run wait_orient.

	print "burn".
	until abs(ang) > 10 or ang_inc < 0.1 {
		clearscreen.
		print "MATCH INC".
		print "==================================".
		print "ang          " + ang.
		print "phase        " + ang_inc.
		print "est rem burn " + est_rem_burn.
		
		//lock throttle to min(1, 10 * ang_inc / ang_inc_start).
		lock throttle to max(0, min(1, est_rem_burn / 10 + 0.01)).
		
		wait 0.1.
	}
	lock throttle to 0.
	print "cooldown".
	wait 5.
}











