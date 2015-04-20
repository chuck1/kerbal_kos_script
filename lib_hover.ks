
declare function hover {
	parameter arg_vert.
	parameter arg_surf.

	util_log("hover").
	
	sas off.
	rcs off.
	lights on.
	
	local mode_surf is 0.
	local hover_alt is 15.	

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
		set mode_vert to "asl".

		set hover_dest to arg_surf[1].
		
		set hover_alt to hover_dest[1].
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
	
	lock twr to accel_max / g.
	
	lock v_srf to vectorexclude(up:vector, ship:velocity:surface).
	
	
	
	
	// ===================================================
	// altitude control
	
	set kp0 to 0.30 / twr.
	set kd0 to 0.50.
	set ki0 to 0.01.
	
	set I0 to 0.
	
	set P0 to 0.
	
	
	lock D0 to 0 - ship:verticalspeed.
	
	lock Y0 to P0 * kp0 + D0 * kd0 + I0 * ki0.
	
	// ==================================================
	// alternate altitude control
	
	
	set vs_target to 0.
	
	lock vs_error to max(0, vs_target - ship:verticalspeed).
	
	// ===================================================
	// surface speed control
	
	
	set dP1dt to V(0,0,0).
	
	if mode_surf = "speed" {
	
		set kp1 to 0.10.
		set kd1 to 1.00.
		set ki1 to 0.
	
		lock P1 to v - v_srf.
	
		lock D1 to dP1dt.
	
	} else if mode_surf = "latlng" {
	
		set kp1 to  0.01.
		set kd1 to  0.10.
		set ki1 to  0.0.
	
		set P1_mag_0 to 0.
		set dLLEdt to 0.
	
		lock lat_error  to hover_dest[0]:lat  - latitude.
		lock long_error to hover_dest[0]:lng - longitude.
	
	
		lock hover_latlng_p to hover_dest[0]:position - ship:position.
		
		lock hover_latlng_p_surf to vxcl(up:vector, hover_latlng_p).
	
		//lock P1 to north:vector * lat_error - east:vector * long_error.
	
		lock P1 to hover_latlng_p_surf.
	
		// vector from ship to target
		
		//lock v_surf_target_perp to vxcl(hover_latlng_p_surf, v_srf).
		//lock v_surf_target to v_srf - v_surf_target_perp.
	
		lock D1 to -1 * v_srf.
		//lock D1 to -1 * v_surf_target.
	} else if mode_surf = "none" {
		//lock P1 to V(0,0,0).
		//lock D1 to V(0,0,0).
	} else {
		print "invalid surface mode: " + mode_surf.
		print neverset.
	}
	
	set P1_0 to V(0,0,0).
	set I1   to V(0,0,0).
	
	if mode_surf = "none" {
		lock P1 to V(0,0,0).
		lock D1 to V(0,0,0).
		lock Y1 to V(0,0,0).
	} else {
		lock Y1 to P1 * kp1 + D1 * kd1 + I1 * ki1.
	}
	
	
	// ================================================
	// user input
	
	on ag1 {
		set I1 to V(0,0,0).
		preserve.
	}
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
	
	// ==============================================
	// for descending
	
	lock hover_arrest_descent_accel to (0 - ship:verticalspeed^2) / (2 * P0) + g.
	lock hover_arrest_descent_thrott to hover_arrest_descent_accel / accel_max.
	
	// ===================================================
	// desired direction
	
	lock down_angle_actual to vang(ship:facing:vector, up:vector).
	
	//lock down_angle to 
	//	min(
	//		arctan2(Y1:mag, -Y0),
	//		hover_down_angle_limit
	//	).
	lock down_angle to 
		min(
			arctan2(Y1:mag, -1),
			hover_down_angle_limit
		).
	
	
	set th to 0.
	
	lock throttle to th.
	
	// ========================================================
	
	set radar_limit to 200.
	
	set t0 to time:seconds.
	
	until 0 {
	
		set dir to up:vector * cos(down_angle) + Y1:normalized * sin(down_angle).
	
		set dt to time:seconds - t0.
		set t0 to time:seconds.	
	
		// ==========================================
		// altitude error
	
		if mode_vert = "agl" {
			lock P0 to hover_alt - alt:radar.
		} else if mode_vert = "asl" {
			if alt:radar < radar_limit {
				lock P0 to max(
					radar_limit - alt:radar,
					hover_alt - altitude).
			} else {
				lock P0 to (hover_alt - altitude).
			}
		} else {
			print "invalid vert mode: " + mode_vert.
			print neverset.
		}
	
	
	
		if P0 > 0 {
			// ascend
			set vs_target to sqrt(2 * g * P0).
		} else {
			// descend
			//lock vs_target to -1 * sqrt(2 * g * P0).
	
			if ship:verticalspeed < 0 {
			
				if hover_arrest_descent_thrott > 0.5 {
					set vs_target to -1.
				} else {
					set vs_target to -100.
				}
			} else {
				set vs_target to -100.
			}
		}
	
		if alt:radar > 2000 {
			set hover_down_angle_limit to 30.
		} else {
			set hover_down_angle_limit to 30.
		}
	
		// =======================================================
		// end conditions
	
		if mode_surf = "latlng" {
			if abs(ship:verticalspeed < 0.1) and abs(P0) < 5 and P1:mag < 0.01 {
				if radar_limit > 10 {
					set radar_limit to 10.
				} else {
					break.
				}
			}
		} else if mode_surf = "none" {
			//if abs(P0) < 1 {
			//	break.
			//}
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
	
			set I0 to I0 + P0 * dt.
			if ship:verticalspeed < 0 {
				set I0 to 0.
			}
			if abs(P0 > 100) {
				set I0 to 0.
			}
	
	
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
			//set th to Y0.
			// analytical control
			
			set th_vert to vs_error / accel_max.
			
			set th to max(0, min(1, th_vert / cos(down_angle_actual))).
		}
		
		// ======================================
		// print
		clearscreen.
		print "HOVER".
		print "==================================================".
		
		print "hover alt       " + hover_alt.
		print "hover vert mode " + mode_vert.
		print "altitude        " + altitude.
		print "alt:radar       " + alt:radar.
		print "alt error       " + P0.
		print "radar limit     " + radar_limit.
		print "v_srf:mag       " + v_srf:mag.
		print "vs error        " + vs_error.
		print "vs target       " + vs_target.
		print "arrest desc a   " + hover_arrest_descent_accel.
		print "arrest desc th  " + hover_arrest_descent_thrott.
		print "thrust ship     " + thrust_ship:mag.
		//print "P0            = " + P0.
		//print "I0            = " + I0.
		//print "D0            = " + D0.
		//print "Y0            = " + Y0.
		//print "Y1              " + vdot(Y1, hover_latlng_p_surf:normalized).
		//print "D1:mag        = " + D1:mag.
		//print "P1:mag        = " + P1:mag.
		//print "I1:mag        = " + I1:mag.
		print "dP1dt:mag       " + dP1dt:mag.
		print "down angle act  " + down_angle_actual.
		print "down angle      " + down_angle.
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

