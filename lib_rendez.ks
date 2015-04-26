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
	
	
	
	lock vel to ship:velocity:orbit - target:velocity:orbit.
	
	// point at docking port
	lock steering to (-1 * dp:portfacing:vector):direction.
	util_wait_orient().
	
	
	// move in at 0.1 m/s towards target
	lock v0 to o:normalized * 0.1.
	
	lock v_burn to v0 - vel.
	
	lock P to o.
	lock D to vel.
	
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
	
	lock vel to ship:velocity:orbit - target:velocity:orbit.
	
	// positive indicates moving toward target
	lock d to vdot(o,v).
	
	// velocity component perpendicular to position vector
	lock v_perp to vxcl(o,v).
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	// set v
	
	// goal is to reach target in 60 seconds
	lock v0 to o / 60.
	
	//lock burn_time_max to v_burn:mag / accel_max.
	
	// desired accel is accel needed for 1 second burn
	
	lock v_burn to v0 - vel.

	lock accel to v_burn:mag / 1.

	lock th0 to accel / accel_max.

	lock steering to v_burn:direction.


	local th is 0.
	lock throttle to th.	
	
	until o:mag < 2500 {

		
		// wait until significant burn is needed
		until (v_burn:mag / v:mag) > 0.1 {
			clearscreen.
			print "wait for burn".
		}
		
		// burn
		until v_burn:mag < 0.1 or o:mag < 2500 {

			clearscreen.
			if vang(steering:vector, ship:facing:vector) > 1 {
				print "reorient".
				set th to 0.
			} else {
				set th to max(0, min(1, th0)).

				print "burn".
				print "th " + th.
				print "dv " + v_burn:mag.
			}
		}
	
		set th to 0.
	
	
		wait 0.1.
	}

	lock throttle to 0.
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
	
	lock vel to ship:velocity:orbit - target:velocity:orbit.
	
	// positive indicates moving toward target
	lock d to vdot(o,v).
	
	// velocity component perpendicular to position vector
	lock v_perp to vectorexclude(vel, o_dp).
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	// set v
	
	// goal is to reach target in 60 seconds
	lock v0 to o / 30.
	
	lock v_burn to v0 - vel.
	
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

	print "rendez " + target.

	local ot is calc_obt_type(ship).
	
	if (ot = "prelaunch") or (ot = "landed") {
		//wait_for_rendez_launch_window().
	}
	
	mvr_match_inc_with_target().

	// orbital planes now match
	
	if (target:obt:eccentricity > 1.1) or (target:obt:eccentricity < 0.9) {
		// eccentric
		// be lazy and just rendezvous at target apoapsis
	
		print "target is eccentric".
	
		set p_s to ship:obt:period.
		set p_t to target:obt:period.

		local mode is 0.
		
		if target:obt:apoapsis < 0 {
			set mode to "p".
		} else {
			if ship:obt:semimajoraxis < target:obt:semimajoraxis {
				set mode to "p".
			} else {
				set mode to "a".
			}
		}

		if mode = "p" {
			if circle(target:periapsis) > 0 {
				return 1.
			}
		
			// ship ta at target apoapsis
			lock ta0 to 
				target:obt:argumentofperiapsis
				- ship:obt:argumentofperiapsis.
	

			set ta to math_clamp_angle(ta0).


			// sweep to target apoapsis
			lock swp to math_clamp_angle(ta - ship:obt:trueanomaly).
	
			// ship eta to target apoapsis
			set e_s to swp / 360 * ship:obt:period.

			// target eta to target periapsis
			set e_t to calc_obt_time_to_periapsis(target).
			
			// target eta to target apo when ship is at apo
			set e_t_0 to e_t - e_s.	


			print "ship ta at target periapsis                  " + round(ta,1).
			print "ship eta to target periapsis                 " + sprint_clock(e_s).
			print "target eta to target per                     " + sprint_clock(e_t).
			print "target eta to target per when ship is at per " + sprint_clock(e_t_0).
			print "target to ship period ratio                  " + round(p_t/p_s,2).

			// for now just choose K_s
			if target:obt:apoapsis < 0 {
				set k_s to floor(e_t/p_s).
			} else {
				set k_s to floor(p_t/p_s).
			}
		} else {
			if circle(target:apoapsis) > 0 {
				return 1.
			}
		
			// ship ta at target apoapsis
			lock ta0 to 
				target:obt:argumentofperiapsis
				- ship:obt:argumentofperiapsis + 180.

			
			set ta to math_clamp_angle(ta0).


			// sweep to target apoapsis
			lock swp to math_clamp_angle(ta - ship:obt:trueanomaly).
	
			// ship eta to target apoapsis
			set e_s to swp / 360 * ship:obt:period.
	
			// target eta to target apo when ship is at apo
			set e_t_0 to calc_obt_time_to_apoapsis(target) - E_s.

			print "ship ta at target periapsis  " + ta.
			print "ship eta to target periapsis " + e_s.
			print "target eta to target apo when ship is at apo " + e_t_0.
		
			// for now just choose K_s
			set k_s to 10.
		}
		
	
		if E_t_0 < 0 {
			lock E_t to E_t_0 + target:obt:period.
		} else {
			lock E_t to E_t_0.
		}
	
		// subscripts
		// t target
		// s ship
		// variables
		// p period
		// k is number of cycles til encounter
	

		print "original".
		print "period ship    " + p_s.
		print "period target  " + p_t.

		local k_t is 0.
	
		if target:obt:apoapsis < 0 {
			set k_t to 0.
		} else {
			// using old P_s
			set k_t to (k_s * p_s - E_t) / p_t.
			
			set k_t to round(k_t, 0).
		}
		
		
		// desired ship period
		set p_s to (k_t * P_t + E_t) / K_s.
	
		print "new".
		print "period ship    " + p_s.
		print "cycles ship    " + k_s.
		print "cycles target  " + k_t.

		print p_s + " * " + k_s + " = " + K_t + " * " + P_t + " + " + E_t.

		if P_s > ship:obt:period {
			lock steering to prograde.
			lock error to P_s - ship:obt:period.
			set w_str to "per".
		} else {
			lock steering to retrograde.
			lock error to ship:obt:period - P_s.
			set w_str to "apo".
		}
		
		warp_time(e_s).
		//wait until 0.
	
		util_wait_orient().
	
		print "burn".
	
		set th to 0.
		lock throttle to th.
		until error < 0 {
			clearscreen.
			print "burn".
			print "period target " + p_s.
			print "period        " + ship:obt:period.
			set th to 0.1.
		}
		set th to 0.
		lock throttle to 0.
		
		print "burn complete".
	
		warp_time((k_s - 0.5) * ship:obt:period).
		
		warp_to(w_str, 120).
	} else {
		// circular
	
		circle(ship:apoapsis).
	
		run wait_for_transfer_window(target).
		
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
	
	
	
	lock vel to ship:velocity:orbit - target:velocity:orbit.
	
	// point at docking port
	//lock steering to (-1 * dp:portfacing:vector):direction.
	//run wait_orient.
	
	// move in at 1 m/s towards target
	lock v0 to o / 30.
	
	lock v_burn to v0 - vel.
	
	lock P to o.
	lock D to vel.
	
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

