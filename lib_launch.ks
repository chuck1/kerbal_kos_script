
function launch_atm {
	parameter launch_altitude.
	
	util_log("launch_atm " + ship:body).
	
	if ship:maxthrust = 0 {
		stage.
	}
	
	print "launch!".
	lock throttle to 0.8.
	lock steering to up + R(0,0,180).
	
	if legs {
		set legs to false.
	}
	
	
	if not (ship:body:atm:exists) {
		print "ERROR no atm".
		print neverset.
	}
	
	lock east_vec to vcrs(north:vector, up:vector).
	
	set steering_deflection_limit to 10.
	lock down_angle_vel to vang(up:vector, ship:velocity:surface).
	
	// with FAR mod, kOS returns approx 3x terminal velocity
	
	//lock term_speed_scale to 12.
	
	lock g to ship:body:mu / (ship:body:radius + altitude)^2.
	lock pres to ship:body:atm:sealevelpressure * ( constant():e ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).
	
	set ship_k to 0.02.
	
	//lock term_speed to ship:termvelocity / term_speed_scale).
	lock term_speed to sqrt(2 * ship:mass * g / pres / ship_k).
	
	lock speed_target to term_speed.
	
	lock launch_atm_p to speed_target - ship:velocity:surface:mag.
	set th to 0.
	lock throttle to th.
	
	set launch_atm_kp to 0.01.
	
	
	set pres_stage to 0.14.
	
	
	// modes
	// 10 countdown
	// 20 leg 1
	// 30 grav turn
	// 40 coast
	
	set mode to 20.
	
	until 0 {
	
		clearscreen.
		print "======================================".
		print "LAUNCH ATM".
		print "======================================".
	
		if mode = 20 {
			print "launch".
	
			set th to launch_atm_p * launch_atm_kp.
	
			if pres < pres_stage {
				// transition to mode 30
	
				set altitude_turn_start to altitude.
	
				set mode to 30.
			}
		} else if mode = 30 {
			print "gravity turn".
		
	
			set down_angle_target to
				min(
					0 + ((altitude - altitude_turn_start) / (5 * altitude_turn_start)) * 60,
					60).
				
				
			// steering deflection: angle between velocity and target steering vectors
			// clamp steering delfection
			set steering_deflection to
				max(
					-steering_deflection_limit,
					min(
						steering_deflection_limit,
						(down_angle_target - down_angle_vel)
					)).
				
			set down_angle_steering to (steering_deflection + down_angle_vel).
				
			set steering_vec to up:vector * cos(down_angle_steering) - east_vec * sin(down_angle_steering).
				
			lock steering to R(
				steering_vec:direction:pitch,
				steering_vec:direction:yaw,
				ship:facing:roll).
	
			if altitude < (ship:body:atm:height - 1000) {		
				set th to launch_atm_p * launch_atm_kp.
			} else {
				set th to 1.
			}
	
			if apoapsis > launch_altitude {
				// transition to mode 40
	
				set th to 0.
				lock throttle to 0.
	
				set mode to 40.
			}
		} else if mode = 40 {
			print "coast out of atm".
			
			if altitude > ship:body:atm:height {
				util_ship_jettison_fairings.
				break.
			}
		}
	
		print "======================================".
		
		if mode = 20 {
		print "    wait for pres       " + pres_stage.
		print "    pres                " + pres.
		}
		if mode < 40 {
		print "    term vel            " + round(term_speed, 1).
		print "    vel                 " + round(ship:velocity:surface:mag, 1).
		}
		print "    th                  " + th.
		if (mode = 30) and 0 {
		print "    apoapsis target     " + round(launch_altitude,0).
		print "    apoapsis            " + round(altitude,0).
		print "    down angle vel      " + round(down_angle_vel,1).
		print "    down angle target   " + round(down_angle_target,1).
		print "    steering deflect    " + round(steering_deflection,1).
		print "    down_angle_steering " + round(down_angle_steering,1).
		}
	
		run util_stage_burn.
	
		wait 0.01.
	}
	
	wait 5.

}

function launch {
	parameter launch_altitude.
	
	util_log("launch " + ship:body).
	
	set warp to 0.
	sas off.
	rcs off.
	
	set get_stable_orbits_body to ship:body.
	run get_stable_orbits.
	
	if launch_altitude = 0 {
		set launch_altitude to ship:body:radius / 5.
	}
	
	if periapsis > get_stable_orbits_ret[0][0] {
		print "already in orbit".
	} else {
		if ship:body:atm:exists {
			launch_atm(launch_altitude).
		} else {
			run launch_no_atm.
		}
	}
}

print "loaded library launch".

