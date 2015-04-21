function mvr_match_inc {
	parameter mvr_match_inc_target.
	
	print "mvr_match_inc " + mvr_match_inc_target.
	
	sas off.
	rcs off.
	set warp to 0.
	lock throttle to 0.
	
	util_log("mvr_match_inc " + mvr_match_inc_target).
	
	if not (calc_obt_type(ship) = "circular") {
		print "orbit must be circular".
		
		if not (circle(0) = 0) {
			return 1.
		}.
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
	
		run warp_time(ang / (360 - ship:obt:trueanomaly) * eta:periapsis - 30).
	
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
			
			clearscreen.
			print "MATCH INC".
			print "==================================".
			
			if mode = 0 {
				print "    waiting for burn window " + abs(ang).
				set thrott to 0.
			} else if mode = 1 {
				print "    burning".
				set thrott to max(0, min(1, est_rem_burn / 10 + 0.05)).
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

	return 0.
}	
function mvr_burn {
	parameter burn_deltav.
	
	lock steering to prograde.
	run wait_orient.
	
	set v0 to ship:velocity:orbit:mag.
	
	lock dv_rem to burn_deltav - (ship:velocity:orbit:mag - v0).
	
	lock accel to ship:maxthrust / ship:mass.
	
	lock est_rem_burn to abs(dv_rem / accel).
	
	set th to 0.
	lock throttle to th.
	
	until dv_rem < 0 {
	
		set th to max(0, min(1, est_rem_burn / 10 + 0.01)).
		
		clearscreen.
		print "BURN".
		print "====================================".
		print "    v0     " + v0.
		print "    v      " + ship:velocity:orbit:mag.
		print "    dv     " + burn_deltav.
		print "    dv rem " + dv_rem.
		print "    eta    " + est_rem_burn.
		
	}
	
	lock throttle to 0.
}
function mvr_adjust_at_apoapsis {
	parameter mvr_adjust_altitude.

	print "mvr_adjust_at_apoapsis " + mvr_adjust_altitude.
	
	util_log("mvr_adjust_at_apoapsis " + mvr_adjust_altitude).
	
	set precision to 0.02.
	
	// ==================================================
	// preliminaries
	sas off.
	set warp to 0.
	lock throttle to 0.
	
	// ==================================================
	// variables
	
	lock error_max to max(
		abs((apoapsis  - mvr_adjust_altitude)/mvr_adjust_altitude),
		abs((periapsis - mvr_adjust_altitude)/mvr_adjust_altitude)).
	
	set accel_max to ship:maxthrust / ship:mass.

	until accel_max > 0 {
		stage.
		set accel_max to ship:maxthrust / ship:mass.
	}
	
	
	// ===========================================
	// mode = 1
	
	print "approaching apoapsis " + apoapsis.
	
	lock alt to periapsis.
	
	set alt_burn to apoapsis.
	
	
	local dv0 is calc_deltav(alt_burn, alt, mvr_adjust_altitude).
	
	set v0 to ship:velocity:orbit:mag.
	
	lock dv_rem to dv0 - (ship:velocity:orbit:mag - v0).
	
	set est_rem_burn to abs(dv_rem / accel_max).
	
	local burn_duration is calc_burn_duration(abs(dv0)).
	if burn_duration = 0 {
		set burn_duration to est_rem_burn.
	}
	
	util_warp_apo(burn_duration / 2 + 30).
	
	local r is (ship:position - ship:body:position).
	
	//local h is vcrs(r, ship:velocity:orbit).
	
	local v_tang is vxcl(r, ship:velocity:orbit).
	
	local myprograde   is (     v_tang:normalized):direction.
	local myretrograde is (-1 * v_tang:normalized):direction.
	
	local dir is (math_sign(dv0) * v_tang:normalized):direction.
	
	local err is 0.
	
	lock err to mvr_adjust_altitude - alt.
	
	global lock steering to R(
		dir:pitch,
		dir:yaw,
		ship:facing:roll).
	
	
	if 0 {
	if dv0 < 0 {
		global lock steering to R(
			myretrograde:pitch,
			myretrograde:yaw,
			ship:facing:roll).
	
		lock err to alt - mvr_adjust_altitude.
	} else {
		global lock steering to R(
			myprograde:pitch,
			myprograde:yaw,
			ship:facing:roll).
	
		
	}
	
	//wait until vang(steering:vector, ship:facing:vector) < 1.
	}
	util_wait_orient().
	
	
	// ============================================================
	
	
	lock e to eta:apoapsis.
	
	
	// use argument of periapsis to detect flip
	set aop0 to ship:obt:argumentofperiapsis.
	
	when abs(aop0 - ship:obt:argumentofperiapsis) > 90 then {
		print "flip! aop = " + ship:obt:argumentofperiapsis.
		lock alt to apoapsis.
	}
	
	// error increase debounce
	local error_counter is 0.
	
	// initial variable which are updated until burn starts
	set v0        to ship:velocity:orbit:mag.
	local err_min   is abs(err).
	set err_start to err.
	
	//lock mvr_eta to e - est_rem_burn/2.
	lock mvr_eta to e - burn_duration/2.
	
	if mvr_eta < 0 {
		print "ERROR: missed burn start time".
		print neverset.
	}
	
	set mvr_eta_0 to mvr_eta.
	wait 0.001.
	
	// mode
	// 10 pre-burn
	// 20 burning
	
	local mode is 10.
	
	// loop
	
	set th to 0.
	lock throttle to th.
	
	//until (err / err_start) < precision {
	until 0 {
	
		set accel_max to ship:maxthrust / ship:mass.
		until accel_max > 0 {
			stage.
			set accel_max to ship:maxthrust / ship:mass.
			
		}
		
		set est_rem_burn to abs(dv_rem / accel_max).
		
		util_ship_stage_burn().
	
		clearscreen.
		print "MVR ADJUST AT APOAPSIS".
		print "=======================================".
		print "    alt target   " + mvr_adjust_altitude.
		print "    apoapsis     " + apoapsis.
		print "    periapsis    " + periapsis.
		print "    alt burn     " + alt_burn.
		print "    err          " + err.
		print "    err_min      " + err_min.
		print "    dv           " + round(dv0,1).
		print "    dv rem       " + round(dv_rem,1).
		print "    accel max    " + accel_max.
		print "    est rem burn " + est_rem_burn.
		print "    throttle     " + round(th,3).
		print "    v mag 0      " + round(v0,1).
		print "    v mag        " + round(ship:velocity:orbit:mag,1).
		print "    burn dur     " + burn_duration.
		print "    error count  " + error_counter.
		if mode = 10 {
			print "burn in t-" + round(mvr_eta,1).
			
			set v0 to ship:velocity:orbit:mag.
			
			if mvr_eta < 0 {
				set mode to 20.
			}
		} else if mode = 20 {
		
			set th to max(0, min(1, est_rem_burn / 10 + 0.01)).
	
			set err_min to min(err_min, abs(err)).
		
			if abs(err) > abs(err_min) {
				set error_counter to error_counter + 1.
				if error_counter > 10 {
					print "abort: error increasing!".
					break.
				}
			} else {
				set error_counter to 0.
			}
	
			if 0 {
			if abs(err / ship:obt:semimajoraxis) < precision {
				print "burn complete".
				break.
			}
			}
		}
	
		wait 0.1.
	}
	
	lock throttle to 0.
	print "cooldown".
	wait 5.
	
	
	// ===================================================
	// ensure burn extrema has passed
	if 0 {
	print "let extrema pass".
	if mode = 0 {
		if eta:periapsis < eta:apoapsis {
			run warp("per",0).
		}
	} else if mode = 1 {
		if eta:periapsis > eta:apoapsis {
			run warp("apo",0).
		}
	}
	}
	
	//cleanup
	unlock steering.
}
function mvr_adjust_at_periapsis {
	parameter mvr_adjust_altitude.
	
	util_log("mvr_adjust_at_apoapsis " + mvr_adjust_altitude).
	
	// prereq
	//run mvr_safe_periapsis.
	
	set precision to 0.02.
	
	
	// ==================================================
	// preliminaries
	sas off.
	rcs off.
	lock throttle to 0.
	
	// ==================================================
	// variables
	
	lock error_max to max(
		abs((apoapsis  - mvr_adjust_altitude)/mvr_adjust_altitude),
		abs((periapsis - mvr_adjust_altitude)/mvr_adjust_altitude)).
	
	lock accel to ship:maxthrust / ship:mass.
	
	
	if apoapsis < 0 {
		set mode to 0.
	} else if periapsis < 0 {
		set mode to 1.
	} else {
		if eta:periapsis < eta:apoapsis {
			set mode to 0.
		} else {
			set mode to 1.
		}
	}
	
	// mode = 0
	print "approaching periapsis " + periapsis.
	lock alt to apoapsis.
	set alt_burn to periapsis.
	
	
	local dv0 is calc_deltav(alt_burn, alt, mvr_adjust_altitude).
	
	
	set v0 to ship:velocity:orbit:mag.
	
	lock dv_rem to dv0 - (ship:velocity:orbit:mag - v0).
	
	lock est_rem_burn to abs(dv_rem / accel).
	
	
	util_warp_per(est_rem_burn/2 + 30).
	
	if dv0 < 0 {
		lock steering to R(
			retrograde:pitch,
			retrograde:yaw,
			ship:facing:roll).
	
		lock err to alt - mvr_adjust_altitude.
	} else {
		lock steering to R(
			prograde:pitch,
			prograde:yaw,
			ship:facing:roll).
	
		lock err to mvr_adjust_altitude - alt.
	}
	util_wait_orient().
	
	// ============================================================
	
	
	lock e to eta:periapsis.
	
	
	
	// use argument of periapsis to detect flip
	set aop0 to ship:obt:argumentofperiapsis.
	
	when abs(aop0 - ship:obt:argumentofperiapsis) > 90 then {
		print "flip! aop = " + ship:obt:argumentofperiapsis.
		
		lock alt to periapsis.
		set mode to 1.
		
	}
	
	// error increasing debounce
	local error_counter is 0.
	
	// initial variable which are updated until burn starts
	set v0        to ship:velocity:orbit:mag.
	set err_min   to err.
	set err_start to err.
	
	lock frac to abs(err / err_start).
	
	set th to 0.
	lock throttle to th.
	
	lock mvr_eta to e - est_rem_burn/2.
	
	if mvr_eta < 0 {
		print "ERROR: missed burn start time".
		wait until 0.
	}
	
	set mvr_eta_0 to mvr_eta.
	
	// 10 pre-burn
	// 20 burning
	local mode is 10.
	
	set err_min   to err.
	set err_start to err.
	
	until 0 {
	
		clearscreen.
		print "MVR ADJUST AT PERIAPSIS".
		print "=======================================".
		print "    alt target   " + mvr_adjust_altitude.
		print "    alt          " + alt.
		print "    alt burn     " + alt_burn.
		print "    err          " + err.
		print "    err_min      " + err_min.
		print "    dv           " + dv0.
		print "    ship accel   " + accel.
		print "    est rem burn " + est_rem_burn.
		print "    throttle     " + round(max(0, min(1, est_rem_burn / 10 + 0.01)),3).
		print "    v mag 0      " + v0.
		print "    v mag        " + ship:velocity:orbit:mag.
		print "    dv rem       " + dv_rem.
		print "    error count  " + error_counter.
		
	
		if mode = 10 {
			print "burn in t-" + round(mvr_eta,1).
			
			set v0 to ship:velocity:orbit:mag.
			
			if mvr_eta < 0 {
				set mode to 20.
			}
		} else if mode = 20 {
		
			set th to max(0, min(1, est_rem_burn / 10 + 0.01)).
	
			set err_min to min(err_min, abs(err)).
		
			if abs(err) > abs(err_min) {
				set error_counter to error_counter + 1.
				if error_counter > 10 {
					print "abort: error increasing!".
					break.
				}
			} else {
				set error_counter to 0.
			}
	
			if 0 {
			if abs(err / ship:obt:semimajoraxis) < precision {
				print "burn complete".
				break.
			}
			}
		}
	
		wait 0.1.
	}
	
	lock throttle to 0.
	print "cooldown".
	wait 5.
	
	
	// ===================================================
	// ensure burn extrema has passed
	
	if 0 {
	print "let extrema pass".
	if eta:periapsis < eta:apoapsis {
		set warp_string to "per".
		set warp_sub to 0.		
		run warp.
	}
	}
}
function mvr_ballistic {
	
	set gc to mun_arch[0].
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	
	// velocity components
	
	lock v_surf to vxcl(up:vector, ship:velocity:surface).
	
	// displacement vector from ship to gc
	lock r to gc:altitudeposition(mun_arch[1]) - ship:position.
	
	// component tangent to body
	lock t to vxcl(up:vector, r).
	
	lock ry to r - t.
	
	// components of tangent that is perpendicular to surface velocity
	lock tz to vxcl(v_surf, t).
	
	// components of tangent that is parallel to surface velocity
	lock rx to t - tz.
	
	// distances
	lock dx to vdot(rx, v_surf:normalized).
	lock dy to vdot(ry, up:vector).
	
	
	lock g to -1 * ship:body:mu / ship:body:radius^2.
	
	
	until 0 {
	
	
		set u0 to ship:surfacespeed.
		set u1 to 0.
	
		set v0 to ship:verticalspeed.
		set v1 to 0.
		
		set ax to (u1^2 - u0^2) / 2.0 / dx.
		
		set ay to (v1^2 - v0^2) / 2.0 / dy - g.
		
		set a to sqrt(ax^2 + ay^2).
	
		set theta to arctan2(ay,ax).
		
		lock steering to (v_surf:normalized * cos(theta) + up:vector * sin(theta)):direction.
	
		set thrott to a / accel_max.
		
		if dx < 0 {
			break.
		}
	
		clearscreen.
		print "MVR BALLISTIC".
		print "===============================".
	
	
		if thrott < 0.75 {
			print "waiting".
			lock throttle to 0.
		} else {
			print "burning".
			lock throttle to thrott.
		}
	
	
	
		print "===============================".
		print "    dx        " + dx.
		print "    dy        " + dy.
		print "    ax        " + ax.
		print "    ay        " + ay.
		print "    a         " + a.
		print "    theta     " + theta.
		print "    accel max " + accel_max.
		print "    thrott    " + thrott.
	
		wait 0.1.
		
	}
}
function mvr_flyover_deorbit {
	parameter mvr_flyover_deorbit_gc.
	
	util_log("mvr_flyover_deorbit " + mvr_flyover_deorbit_gc).
	
	// useful vats
	lock g to ship:body:mu / (ship:body:radius + altitude)^2.
	lock accel_max to ship:maxthrust / ship:mass.
	lock th_g to g / accel_max.
	//
	
	// calc bearing to latlong
	
	lock s_r to ship:position - ship:body:position.
	
	lock h to vcrs(
		s_r,
		ship:velocity:orbit - ship:body:velocity:orbit).
	
	lock phase to
		vang(s_r, gc_r) *
		vdot(vcrs(s_r, gc_r), h) /
		abs(vdot(vcrs(s_r, gc_r), h)).
	
	lock gc_r to mvr_flyover_deorbit_gc:position - ship:body:position.
	
	lock gc_r_tangent to vxcl(h, gc_r).
	
	lock inc_change to vang(gc_r, gc_r_tangent).
	
	lock inc_sign to 
		vdot(vcrs(gc_r, gc_r_tangent), s_r).
	
	lock dv_rem to 2 * ship:velocity:orbit:mag * sin(inc_change / 2).
	
	set get_highest_peak_body to ship:body.
	run get_highest_peak.
	
	set mvr_flyover_deorbit_highest_peak to get_highest_peak_ret.
	
	lock steering to R(
		retrograde:pitch,
		retrograde:yaw,
		ship:facing:roll).
	
	util_wait_orient().
	
	
	
	// ====================================
	
	// search for land position
	
	set  t_l to time:seconds.
	lock p_l to positionat(ship, t_l).
	lock r_l to p_l - ship:body:position.
	
	// horizontal distance to latlng at t_l
	lock d_l to vxcl(r_l, p_l - mvr_flyover_deorbit_gc:position).
	
	lock alt_l to r_l:mag - ship:body:radius.
	
	// find time at which ship passes below highest peak
	
	// mode
	// 10 wait for phase of 45
	// 20 burn
	
	set mode to 10.
	
	set d_l_min to 10000000000000.
	
	set counter to 0.
	
	until 0 {
	
		clearscreen.
		print "MVR FLYOVER".
		print "=======================================".
	
		if mode = 10 {
			print "wait for phase of 45".
			
			if (45 - phase) > 0 or (45 - phase) < -5 {
				if not (warp = 3) {
					set warp to 3.
				}
			} else {
				if not (warp = 0) {
					set warp to 0.
				}
			}
	
			if (abs(phase - 45) < 1) {
				if not (warp = 0) {
					set warp to 0.
				}
			
				lock throttle to th_g.
				set mode to 20.
			}
		} else if mode = 20 {
	
			print "deorbit".
	
			set t_l to time:seconds.
			until 0 {
				//if alt_l < mvr_flyover_deorbit_gc:terrainheight + 2000 {
				if alt_l < mvr_flyover_deorbit_highest_peak {
					break.
				}
				set t_l to t_l + 1.
			}
		
	
			if d_l:mag > d_l_min {
				lock throttle to th_g / 2.
				
				// anti-jitter
				set counter to counter + 1.
				if counter = 10 {
					lock throttle to 0.
					break.
				}
			}
	
			set d_l_min to min(d_l_min, d_l:mag).
		}
	
		print "==============================".
		print "    distance to lz " + round(d_l_min,0).
	
		wait 0.1.
	}
	lock throttle to 0.
	
	print "distance to target when passing".
	print "through " + round(mvr_flyover_deorbit_highest_peak, 0) +
		" altitude is " + round(d_l_min, 0).
	
	// could use time here to adjust for body rotation
}
function mvr_flyover {
	// PARAM mvr_flyover_gc
	
	util_log("mvr_flyover " + mvr_flyover_gc).
	
	// useful vats
	lock g to ship:body:mu / (ship:body:radius + altitude)^2.
	lock accel_max to ship:maxthrust / ship:mass.
	lock th_g to g / accel_max.
	//
	
	set get_highest_peak_body to ship:body.
	run get_highest_peak.
	
	set mvr_flyover_highest_peak to get_highest_peak_ret.
	
	// prereq: low orbit for better accuracy
	run circle_low.
	
	// calc bearing to latlong
	
	lock s_r to ship:position - ship:body:position.
	
	lock h to vcrs(
		s_r,
		ship:velocity:orbit - ship:body:velocity:orbit).
	
	lock phase to
		vang(s_r, gc_r) *
		vdot(vcrs(s_r, gc_r), h) /
		abs(vdot(vcrs(s_r, gc_r), h)).
	
	lock gc_r to mvr_flyover_gc:position - ship:body:position.
	
	lock gc_r_tangent to vxcl(h, gc_r).
	
	lock inc_change to vang(gc_r, gc_r_tangent).
	
	lock inc_sign to 
		vdot(vcrs(gc_r, gc_r_tangent), s_r).
	
	print "inc change " + inc_change.
	wait 2.
	
	lock dv_rem to 2 * ship:velocity:orbit:mag * sin(inc_change / 2).
	
	
	
	if abs(inc_change) > 0.1 {
	
		// ====================================
		// 10 wait for phase of 90
		// 20 inc change burn
	
		set mode to 10.
	
		until 0 {
	
			clearscreen.
			print "MVR FLYOVER".
			print "===========================================".
		
			if mode = 10 {
				// status line
				print "wait for phase of 90".
	
				// end condition
				if abs(phase - 90) < 1 {
					// transition to mode 1
	
					set inc_sign_0 to inc_sign.
	
					set mode to 20.
				}
	
				// other stuff
				if (90 - phase) > 0 or (90 - phase) < -5 {
					set warp to 2.
				} else {
					set warp to 0.
				}
			} else if mode = 20 {
				// status line
	
				// end conditions
				if (inc_change < 0.1) or ((inc_sign * inc_sign_0) < 0) {
	
					lock throttle to 0.
					print "cooldown".
					wait 5.
	
					break.
				}
				
				// orientation
				if inc_sign < 0 {
					lock steering to R(
						h:direction:pitch,
						h:direction:yaw,
						ship:facing:roll).
				} else {
					lock steering to R(
						(-1 * h):direction:pitch,
						(-1 * h):direction:yaw,
						ship:facing:roll).
				}
	
				// other stuff
				if accel_max > 0 {
					set est_rem_burn to dv_rem / accel_max.
				} else {
					stage.
					wait 1.
					set est_rem_burn to 0.
				}
	
				if vang(steering:vector, ship:facing:vector) > 3 {
					print "change inclination (reorient)".
					lock throttle to 0.
				} else {
					print "change inclination".
					lock throttle to ((est_rem_burn / 5) + 0.01).
				}
			}
	
			print "===========================================".
			print "    phase      " + phase.
			print "    inc change " + inc_change.
	
			wait 0.1.
		}
	
	}
	
	mvr_flyover_deorbit(mvr_flyover_gc).
}

	
print "loaded library mvr".

