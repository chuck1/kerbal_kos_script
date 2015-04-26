function hover_acc_control_alt {
	// use kinematic equ to get vertical acceleration to control altitude
	parameter ves.
	parameter seek.
	parameter curr.
	
	local x is seek - curr.
	
	if x > 0 {
		// ascend
		local v is sqrt(2 * ves_g(ves) * x).
		return (v - ship:verticalspeed).
	} else {
		// descend
	
		if ship:verticalspeed < 0 {
	
			local a is (0 - ship:verticalspeed^2) / (2 * x) + g.
			local t is a / ves_a_max(ves).
			
			if t > 0.5 {
				return (0 - ship:verticalspeed).
			} else {
				return 0.
			}
		} else {
			return 0.
		}
	}
}
function hover {
	parameter arg_vert.
	parameter arg_surf.

	//util_log("hover").
	
	sas off.
	rcs off.
	lights on.
	
	local mode_surf is 0.
	local hover_alt is 15.	
	local hover_dest is 0.

	if arg_surf = 0 {
		set mode_surf to "none".
	} else {
		set mode_surf to arg_surf[0].
	}
	
	if arg_vert = 0 {
		set mode_vert to "agl".
	} else {
		set mode_vert to arg_vert[0].
	}

	if mode_surf = "latlng" {
		set mode_vert  to "asl".
		set hover_dest to arg_surf[1].
		set hover_alt  to hover_dest[1].
	}

	lock east to vcrs(north:vector, up:vector):direction.
	
	//lock v to north:vector * v_north + east:vector * v_east.
	
	lock throttle to 0.
	
	if ship:maxthrust = 0 {
		stage.
	}
	
	local hover_down_angle_limit is 45.
	
	lock g to ship:body:mu / (ship:body:radius + altitude)^2.
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	lock v_srf to vectorexclude(up:vector, ship:velocity:surface).
	
	// =================================================
	
	lock a_surf_max_cruising to g * tan(hover_down_angle_limit).

	lock dist_to_arrest_surf_speed to (ship:surfacespeed^2) / 2 / a_surf_max_cruising.
	
	// ===================================================
	// altitude control

	local kp is 0.50 / ves_twr(ship).

	local pid_vert is pid_init(
		kp,
		kp * 0,
		kp * 6,
		0,
		1).
	
	// ==================================================
	// alternate altitude control
	
	//set vs_target to 0.
	
	//lock vs_error to max(0, vs_target - ship:verticalspeed).
	
	// ===================================================
	// surface speed control
	
	
	set dP1dt to V(0,0,0).

	local pid_surf is 0.
	
	if mode_surf = "speed" {
		
		
		
		set kp1 to 0.10.
		set ki1 to 0.
		set kd1 to 1.00.
	
		lock P1 to v - v_srf.
	
		lock D1 to dP1dt.
	
	} else if mode_surf = "latlng" {
	
		set kp1 to  0.01.
		set kd1 to  0.10.
		set ki1 to  0.0.
	
		set pid_surf to pid_init(0.01, 0, 0.1, 0, 1).
	
		set P1_mag_0 to 0.
		set dLLEdt to 0.
	
		lock lat_error  to hover_dest[0]:lat  - latitude.
		lock long_error to hover_dest[0]:lng - longitude.
	
		lock hover_latlng_p to hover_dest[0]:position - ship:position.
		
		lock hover_latlng_p_surf to vxcl(up:vector, hover_latlng_p).
	
		//lock P1 to north:vector * lat_error - east:vector * long_error.
	
		lock P1 to hover_latlng_p_surf.
	
		// vector from ship to target
		
		lock v_surf_target_perp to vxcl(hover_latlng_p_surf, v_srf).
		lock v_surf_target to v_srf - v_surf_target_perp.
	
		lock D1 to -1 * v_srf.
		//lock D1 to -1 * v_surf_target.
	} else if mode_surf = "none" {
		sas on.
		//lock P1 to V(0,0,0).
		//lock D1 to V(0,0,0).
	} else {
		print "invalid surface mode: " + mode_surf.
		print neverset.
	}
	
	set P1_0 to V(0,0,0).
	set I1   to V(0,0,0).

	local Y1 is V(0,0,0).
	
	if mode_surf = "none" {
		lock P1 to V(0,0,0).
		lock D1 to V(0,0,0).
		lock Y1 to V(0,0,0).
	} else {
		lock Y1 to P1 * kp1 + D1 * kd1 + I1 * ki1.
	}
	
	
	
	// ================================================
	// user input
	
	on ag2 {
		set hover_alt to hover_alt - 10.
		preserve.
	}
	on ag3 {
		set hover_alt to hover_alt + 10.
		preserve.
	}
	on ag4 {
		set hover_lat to hover_lat - .0010.
		preserve.
	}
	on ag5 {
		set hover_lat to hover_lat + .0010.
		preserve.
	}
	on ag6 {
		set hover_long to hover_long - .0010.
		preserve.
	}
	on ag7 {
		set hover_long to hover_long + .0010.
		preserve.
	}
	
	// ===================================================
	// desired direction
	
	lock down_angle_actual to vang(ship:facing:vector, up:vector).
	
	//lock down_angle to 
	//	min(
	//		arctan2(Y1:mag, -Y0),
	//		hover_down_angle_limit
	//	).
	
	local down_angle is 0.
	
	set th to 0.
	
	lock throttle to th.
	
	// ========================================================
	
	set radar_limit to 200.
	
	set t0 to time:seconds.
	
	until 0 {



		if mode_surf = "latlng" {

			set pid_surf_input to pid_seek(pid_surf, 0, hover_latlng_p_surf:mag).

			if 1 {
				set down_angle to 
					math_clamp(
						arctan2(abs(pid_surf_input), -1),
						0,
						hover_down_angle_limit).
			} else {
				set down_angle to 
					math_clamp(
						arctan2(Y1:mag, -1),
						0,
						hover_down_angle_limit).
			}




			if		(dist_to_arrest_surf_speed > hover_latlng_p_surf:mag) and
					(vdot(v_surf_target, hover_latlng_p_surf) > 0) {
				// point away from target
				set dir to up:vector * cos(hover_down_angle_limit) - v_surf:normalized * sin(hover_down_angle_limit).
			} else {
				set dir to up:vector * cos(down_angle) + Y1:normalized * sin(down_angle).
			}
		} else {
			set dir to up:vector * cos(down_angle) + Y1:normalized * sin(down_angle).
		}

	
		set dt to time:seconds - t0.
		set t0 to time:seconds.	
	
		// ==========================================
		// altitude error
	
		if mode_vert = "agl" {
			set alt_seek to hover_alt.
			set alt_curr to alt:radar.
		} else if mode_vert = "asl" {
			if alt:radar < radar_limit {
				if (radar_limit - alt:radar) > (hover_alt - altitude) {
					set alt_seek to radar_limit.
					set alt_curr to alt:radar.
				} else {
					set alt_seek to hover_alt.
					set alt_curr to altitude.
				}
			} else {
				set alt_seek to hover_alt.
				set alt_curr to altitude.
			}
		} else {
			print "invalid vert mode: " + mode_vert.
			print neverset.
		}
	
		set th to ves_th_from_cur_pitch_and_acc(ship, hover_acc_control_alt(ship, alt_seek, alt_curr)).

		set alt_error to alt_seek - alt_curr.

		//set pid_vert_input to pid_seek(pid_vert, 50, alt:radar).

		if alt:radar > 2000 {
			set hover_down_angle_limit to 30.
		} else {
			set hover_down_angle_limit to 30.
		}
	
		// =======================================================
		// end conditions
	
		if mode_surf = "latlng" {
			if abs(ship:verticalspeed < 0.1) and abs(alt_error) < 5 and P1:mag < 0.01 {
				if radar_limit > 10 {
					set radar_limit to 10.
				} else {
					break.
				}
			}
		} else if mode_surf = "none" {
		} else {
			print "invalid surface mode: " + mode_surf.
			print neverset.
		}
		
		// =========================================================
		// when close to target, switch to rcs for surface control
		
		lock thrust_ship to ship:facing:inverse * Y1 * 50.
	
	
		if not (mode_surf = "none") {
			if (P1:mag < 100) and (D1:mag < 5) {
				lock steering to up.
	
				rcs on.
		
				set ship:control:translation to thrust_ship.
			} else {
				lock steering to R(
					dir:direction:pitch,
					dir:direction:yaw,
					ship:facing:roll).
		
				rcs off.
	
				set ship:control:translation to V(0,0,0).
			}
		}
	
		// update control vars
		
		if dt > 0 {
	
			set dP1dt_0 to dP1dt.
			set dP1dt to (P1 - P1_0) / dt.
			set P1_0 to P1.
	
			if mode_surf = "latlng" {
				// start integral control when close
				if P1:mag < 1 {
					set I1 to I1 + P1 * dt.
				}
	
	
				if (dP1dt_0 * dP1dt) < 0 {
					// error rate flip
					set I1 to V(0,0,0).
				}
			}
	
			// pid control

			//set th to pid_vert_input.

			// analytical control
			
			//set th to ves_th_from_cur_pitch_and_acc(ship, vs_error).
			
			//set th to ves_th_from_cur_pitch_and_acc(ship, pid_vert_input + ves_g(ship)).
			
		
		}
		
		// ======================================
		clearscreen.
		print "HOVER".
		print "==================================================".
		
		print "hover alt       " + hover_alt.
		print "hover vert mode " + mode_vert.
		print "altitude        " + altitude.
		print "alt:radar       " + alt:radar.
		print "alt seek        " + alt_seek.
		print "alt curr        " + alt_curr.
		print "alt error       " + alt_error.
		print "radar limit     " + radar_limit.
		print "v_srf:mag       " + v_srf:mag.
		print "dist to arrest surf speed " + dist_to_arrest_surf_speed.
		print "thrust ship     " + thrust_ship:mag.
		print "down angle act  " + down_angle_actual.
		print "down angle      " + down_angle.
		print "th              " + th.
		//print "down angle0     " + arctan2(Y1:mag, Y0).
		
		if mode_surf = "latlng" {
		print "distance        " + hover_dest[0]:distance.
		print "distance surf   " + hover_latlng_p_surf:mag.
		print "lat             " + latitude.
		print "long            " + longitude.
		}
		
		// =========================================
		if 0 {	
		if vang(ship:facing:vector, steering:vector) > 2 and alt:radar > 50 {
			lock throttle to 0.
			print "reorienting".		
		} else {
			lock throttle to th.
		}
		}
		if thrust_ship:mag > 1 {
			print "rcs maxed out".
		}
	
		wait 0.1.
	}
	
	set ship:control:translation to V(0,0,0).
}	

print "loaded library hover".

