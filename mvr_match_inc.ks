declare parameter mvr_match_inc_target.

sas off.
rcs off.
set warp to 0.
lock throttle to 0.

util_log("mvr_match_inc " + mvr_match_inc_target).

if not (calc_obt_type() = "circular") {
	print "orbit must be circular".
	print neverset.
}

// =======================================================================
// variables

lock accel_max to ship:maxthrust / ship:mass.

lock h to vcrs(
	ship:position - ship:body:position,
	ship:velocity:orbit - ship:body:velocity:orbit).

lock h_target to vcrs(
	ship:body:position       - mvr_match_inc_target:position,
	ship:body:velocity:orbit - mvr_match_inc_target:velocity:orbit).

lock v_c to vcrs(h_target, h).

lock v_p to ship:position - ship:body:position.

lock v_c0 to v_c.
lock v_c1 to -1 * v_c.

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

set ang_inc_start to ang_inc.

lock vs to (ship:velocity:orbit - ship:body:velocity:orbit):mag.

lock dv to 2 * vs * sin(ang_inc / 2).

lock est_rem_burn to (dv / accel_max).

// steps


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
	util_wait_orient().

	// loop
	// 0 wait for angle
	// 1 burn
	// 2 cooldown
	set mode to 0.
	
	set thrott to 0.
	lock throttle to thrott.
	until abs(ang) > 10 or ang_inc < 0.1 {
		
		// mode checking
		if mode = 0 and abs(ang) < 5 {
			set mode to 1.
		}
		if mode = 1 and abs(ang) > 5 {
			set mode to 0.
		}
		
		clearcsreen.
		print "MATCH INC".
		print "==================================".
		
		if mode = 0 {
			print "    waiting for burn window " + abs(ang).
			set thrott to 0.
		} else if mode = 1 {
			print "    burning".
			set thrott to max(0, min(1, est_rem_burn / 10 + 0.01)).
		}
		
		print "==================================".
		print "    ang          " + ang.
		print "    phase        " + ang_inc.
		print "    est rem burn " + est_rem_burn.
		
		wait 0.01.
	}

	lock throttle to 0.
	print "cooldown".
	wait 5.
}



