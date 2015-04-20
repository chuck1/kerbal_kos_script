function rendez_final {
	
	lock throttle to 0.
	sas off.
	rcs on.
	
	print "rendez final".
	
	
	// vis
	set vec_thrust to vecdraw().
	set vec_ship_fore to vecdraw().
	set vec_ship_star to vecdraw().
	set vec_ship_up to vecdraw().
	
	set vec_ship_fore:show to true.
	set vec_ship_star:show to true.
	set vec_ship_up:show to true.
	set vec_thrust:show to true.
	
	set vec_ship_fore:color to red.
	set vec_ship_star:color to green.
	set vec_ship_up:color to blue.
	
	// get port
	
	for p in target:parts {
		if p:name = "dockingPort2" {
			print p:name.
			set dp to p.
		}
	}
	
	lock o_dp to dp:position - ship:position.
	
	lock angle_dp to vang(dp:facing:vector, -1 * o_dp).
	
	lock pf to dp:portfacing:vector.
	
	lock pf_perp to vectorexclude(pf, o_dp):normalized.
	
	// maintain distance from target vessel
	lock o to o_dp + pf_perp * 100.
	
	
	
	lock v to ship:velocity:orbit - target:velocity:orbit.
	
	// point at docking port
	lock steering to (-1 * dp:portfacing:vector):direction.
	run wait_orient.
	
	
	// move in at 0.1 m/s towards target
	lock v0 to o:normalized * 0.1.
	
	lock v_burn to v0 - v.
	
	lock P to o.
	lock D to v.
	
	set kp to 0.005.
	set kd to 0.5.
	
	lock thrust to P * kp - D * kd.
	
	lock ship_thrust to ship:facing:inverse * thrust.
	
	until P:mag < 0.01 and D:mag < 0.01 {
	
		//print "ship thrust = " + ship_thrust.
	
		
	
		// vis
		set vec_thrust:start to ship:position.
		set vec_thrust:vector to thrust * 100.
	
		set vec_ship_fore:start to ship:position.
		set vec_ship_star:start to ship:position.
		set vec_ship_up:start to ship:position.
	
		set vec_ship_fore:vector to ship:facing:forevector * 10.
		set vec_ship_star:vector to ship:facing:starvector * 10.
		set vec_ship_up:vector   to ship:facing:upvector * 10.
		
		//set ship:control:fore      to thrust:x * -1.
		//set ship:control:starboard to thrust:y * -1.
		//set ship:control:top       to thrust:z.
	
		set ship:control:translation to ship_thrust.
	
		//wait 0.1.
	}
	
	set ship:control:translation to V(0,0,0).
	
	
	set vec_ship_fore:show to false.
	set vec_ship_star:show to false.
	set vec_ship_up:show to false.
	set vec_thrust:show to false.
	
}

function rendez_approach {
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
}


function rendez_approach_2 {
	
	rcs off.
	
	print "rendezvous approach 2".
	
	// ==========================================
	
	lock o_target to target:position - ship:position.
	
	lock o to o_target.
	
	
	for p in target:parts {
		if p:name = "dockingPort2" {
			print p:name.
			set dp to p.
			break.
		}
	}
	
	// ==========================================
	// determine desired position
	lock o_dp to dp:position - ship:position.
	
	lock angle_dp to vang(dp:facing:vector, -1 * o_dp).
	
	lock pf to dp:portfacing:vector.
	
	lock pf_perp to vectorexclude(o_dp, pf):normalized.
	
	// maintain distance from target vessel
	lock o to o_dp + pf_perp * 200.
	
	
	// until dp is facing the ship
	when angle_dp < 90 then {
		
		print "docking port is in view".
		
		// aim for 100 m off dockingport
		lock o to o_dp + (pf * 200).
	}
	
	// ==========================================
	// vis
	
	set vec_o to vecdraw().
	set vec_o_dp to vecdraw().
	set vec_pf to vecdraw().
	set vec_pf_perp to vecdraw().
	set vec_v to vecdraw().
	
	set vec_o:show to true.
	set vec_o_dp:show to true.
	set vec_pf:show to true.
	set vec_pf_perp:show to true.
	set vec_v:show to true.
	
	// ==========================================
	
	lock v to ship:velocity:orbit - target:velocity:orbit.
	
	// positive indicates moving toward target
	lock d to vdot(o,v).
	
	// velocity component perpendicular to position vector
	lock v_perp to vectorexclude(v,o_dp).
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	// set v
	
	// goal is to reach target in 60 seconds
	lock v0 to o / 30.
	
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
	
	until o:mag < 20 {
	
		
		set vec_o:start to ship:position.
		set vec_o:vector to o.
		set vec_o_dp:start to ship:position.
		set vec_o_dp:vector to o_dp.
		set vec_pf:start to dp:position.
		set vec_pf:vector to pf * 200.
		set vec_pf_perp:start to dp:position.
		set vec_pf_perp:vector to pf_perp * 200.
		set vec_v:start to ship:position.
		set vec_v:vector to v * 10.
	
		
		// wait until significant burn is needed
		until (v_burn:mag / v:mag) > 0.1 {
			
			print "wait for significant burn".
			print "o:mag      = " + o:mag.
			print "v_burn:mag = " + v_burn:mag.
	
			set vec_o:start to ship:position.
			set vec_o:vector to o.
			set vec_o_dp:start to ship:position.
			set vec_o_dp:vector to o_dp.
			set vec_pf:start to dp:position.
			set vec_pf:vector to pf * 200.
			set vec_pf_perp:start to dp:position.
			set vec_pf_perp:vector to pf_perp * 200.
			set vec_v:start to ship:position.
			set vec_v:vector to v * 10.
		}
	
		// burn
		until v_burn:mag < 0.1 or o:mag < 20 {
			set th to max(0.01, min(1, th0)).
			lock throttle to th.
	
			print "burning".
			print "o:mag      = " + o:mag.
			print "v_burn:mag = " + v_burn:mag.
	
			set vec_o:start to ship:position.
			set vec_o:vector to o.
			set vec_o_dp:start to ship:position.
			set vec_o_dp:vector to o_dp.
			set vec_pf:start to dp:position.
			set vec_pf:vector to pf * 200.
			set vec_pf_perp:start to dp:position.
			set vec_pf_perp:vector to pf_perp * 200.
			set vec_v:start to ship:position.
			set vec_v:vector to v * 10.
		}
		lock throttle to 0.
		set th to 0.
	}	

	set vec_o:show to false.
	set vec_o_dp:show to false.
	set vec_pf:show to false.
	set vec_pf_perp:show to false.
	set vec_v:show to false.
}

function rendez {
	parameter is_boot_func.

	print target.

	run mvr_match_inc(target).

	// orbital planes now match
	
	if target:obt:eccentricity > 1.1 {
		// eccentric
		// be lazy and just rendezvous at target apoapsis
		
		circle(target:apoapsis).
	
		// ship ta at target apoapsis
		lock ta0 to 
			target:argumentofperiapsis
			- ship:argumentofperiapsis + 180.
		
		if ta0 < 0 {
			lock ta to ta0 + 360.
		} else if ta0 > 360 {
			lock ta to ta0 - 360.
		} else {
			lock ta to ta0.
		}
	
		// sweep to target apoapsis
		lock swp0 to ta - ship:obt:trueanomaly.
		
		if swp0 < 0 {
			lock swp to swp0 + 360.
		} else if swp0 > 360 {
			lock swp to swp0 - 360.
		} else {
			lock swp to swp0.
		}
	
		// ship eta to target apoapsis
		set E_s to swp / 360 * ship:obt:period.
		
		// target eta to target apo when ship is at apo
		lock E_t_0 to target:eta:apoapsis - E_s.
	
		if E_t_0 < 0 {
			lock E_t to E_t_0 + target:obt:period.
		} else {
			lock E_t to E_t_0.
		}
		
		// for now just choose K_s
		set K_s to 10.
	
		// using old P_s
		set K_t to (K_s * P_s - E_t) / P_t.
		
		set K_t to round(K_t, 0).
		
		// desired ship period
		set P_s to (K_t * P_t + E_t) / K_s.
	
		if P_s > ship:obt:period {
			lock steering to prograde.
			lock error to P_s - ship:obt:period.
			set w_str to "per".
		} else {
			lock steering to retrograde.
			lock error to ship:obt:period - P_s.
			set w_str to "apo".
		}
		
		run warp_time(E_s).
	
		run wait_orient.
	
		print "burn".
	
		set th to 0.
		lock throttle to th.
		until error < 0 {
			set th to 1.
		}
		set th to 0.
		lock throttle to 0.
		
		print "burn complete".
	
		run warp_time((K_s - 0.5) * ship:obt:period).
		
		run warp(w_str, 120).
	} else {
		// circular
	
		circle(ship:apoapsis, 0.01).
	
		run wait_for_transfer_window.
		
		run burn_to(target:altitude, 0.01).
		
		if ship:altitude < target:altitude {	
			run warp("apo", 120).
		} else {
			run warp("per", 120).
		}
	}
	
	rendez_approach().
	rendez_final().
	
	
}


function rendez_viz {
	lock throttle to 0.
	sas off.
	rcs on.
	
	set SHIP:CONTROL:NEUTRALIZE to true.
	
	// vis
	set vec_thrust to vecdraw().
	set vec_ship_fore to vecdraw().
	set vec_ship_star to vecdraw().
	set vec_ship_up to vecdraw().
	
	set vec_ship_fore:show to true.
	set vec_ship_star:show to true.
	set vec_ship_up:show to true.
	set vec_thrust:show to true.
	
	set vec_ship_fore:color to red.
	set vec_ship_star:color to green.
	set vec_ship_up:color to blue.
	
	// get port
	
	for p in target:parts {
		if p:name = "dockingPort2" {
			print p:name.
			set dp to p.
		}
	}
	
	lock o_dp to dp:position - ship:position.
	
	lock angle_dp to vang(dp:facing:vector, -1 * o_dp).
	
	lock pf to dp:portfacing:vector.
	
	lock pf_perp to vectorexclude(pf, o_dp):normalized.
	
	// maintain distance from target vessel
	lock o to o_dp + pf_perp * 100.
	
	
	
	lock v to ship:velocity:orbit - target:velocity:orbit.
	
	// point at docking port
	//lock steering to (-1 * dp:portfacing:vector):direction.
	//run wait_orient.
	
	// move in at 1 m/s towards target
	lock v0 to o / 30.
	
	lock v_burn to v0 - v.
	
	lock P to o.
	lock D to v.
	
	set kp to 0.005.
	set kd to 0.05.
	
	lock thrust to P * kp - D * kd.
	
	until 0 {
	
		print "thrust = " + (ship:facing:inverse * thrust).
		
		// vis
		set vec_thrust:start to ship:position.
		set vec_thrust:vector to thrust * 10.
	
		set vec_ship_fore:start to ship:position.
		set vec_ship_star:start to ship:position.
		set vec_ship_up:start to ship:position.
	
		set vec_ship_fore:vector to ship:facing:forevector * 10.
		set vec_ship_star:vector to ship:facing:starvector * 10.
		set vec_ship_up:vector to ship:facing:upvector * 10.
		
		
		wait 0.5.
	}
	
	
	
	set vec_ship_fore:show to false.
	set vec_ship_star:show to false.
	set vec_ship_up:show to false.
	set vec_thrust:show to false.
}

print "loaded library rendez".

