function obt_at_body {
	parameter ob.
	parameter bdy.
	
	print "obt_at_body".
	print "    bdy     " + bdy.
	print "    ob:body " + ob:body.
	
	if ob:body = bdy {
		return ob.
	} else if (ob:hasnextpatch) {
		if ob:nextpatch:body = bdy {
			return ob:nextpatch.
		}
	}
	
	print neverset.
}
function obt_lan_at_body {
	parameter obt.
	parameter bdy.
	
	if obt:body = bdy {
		return obt:lan.
	} else if (obt:hasnextpatch) {
		if obt:nextpatch:body = bdy {
			return obt:nextpatch:lan.
		}
	}
	
	print neverset.
}
function obt_inc_at_body {
	parameter obt.
	parameter bdy.
	
	if obt:body = bdy {
		return obt:inclination.
	} else if (obt:hasnextpatch) {
		if obt:nextpatch:body = bdy {
			return obt:nextpatch:inclination.
		}
	}
	
	print neverset.
}
function mvr_match_inc_with_target {
	
	print "mvr_match_inc_with_target".

	wait_for_rendez_launch_window().
	
	local i is obt_inc_at_body(target:obt, ship:body).
	
	local hv is obt_h_for(ship).

	until 0 {
	
		local del_i is i - ship:obt:inclination.
	
		lock steering to (-1 * hv * math_sign(del_i)):direction.

		lock throttle to 0.1.

		if abs(del_i) < 0.1 {
			break.
		}
	}
	lock throttle to 0.
}
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
	
		warp_time(ang / (360 - ship:obt:trueanomaly) * eta:periapsis - 30).
	
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
				set thrott to ves_thrott_from_burn_dur(ship, dv).
			}
			
			print "==================================".
			print "    ang          " + ang.
			print "    phase        " + ang_inc.
			
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
	
	set th to 0.
	lock throttle to th.
	
	until dv_rem < 0 {
	
		set th to ves_thrott_from_burn_dur(ves_dv_rem).
		
		clearscreen.
		print "BURN".
		print "====================================".
		print "    v0     " + v0.
		print "    v      " + ship:velocity:orbit:mag.
		print "    dv     " + burn_deltav.
		print "    dv rem " + dv_rem.
		
	}
	
	lock throttle to 0.
}
function mvr_adjust_per {
	parameter per.

	// variables
	local dv_rem is 0.
	
	local s is math_sign(per - periapsis).
	
	local dv is calc_dv_from_per(altitude, per).
	local v0 is ship:velocity:orbit:mag.
	
	lock steering to (prograde:vector * s):direction.
	
	util_wait_orient().

	local th is 0.
	lock throttle to th.	
	until 0 {
		// detect sign flip
		if (math_sign(per - periapsis) * s) < 0 {
			break.
		}
	
		set dv_rem to dv - (ship:velocity:orbit:mag - v0).
	
		set th to ves_thrott_from_burn_dur(ship, dv_rem).
	}
	lock throttle to 0.
}
function mvr_adjust_at_apoapsis {
	parameter mvr_adjust_altitude.

	print "mvr_adjust_at_apoapsis " + mvr_adjust_altitude.
	
	util_log("mvr_adjust_at_apoapsis " + mvr_adjust_altitude).

	local orient_time is 120.
	
	set precision to 0.02.
	
	// ==================================================
	// preliminaries
	sas off.
	set warp to 0.
	lock throttle to 0.
	
	// ==================================================
	// variables
	

	util_ship_stage_burn().
	
	// ===========================================
	// mode = 1
	
	print "approaching apoapsis " + apoapsis.
	
	lock alt to periapsis.
	
	set alt_burn to apoapsis.
	
	
	local dv0 is calc_deltav(alt_burn, alt, mvr_adjust_altitude).
	
	set v0 to ship:velocity:orbit:mag.
	
	lock dv_rem to dv0 - (ship:velocity:orbit:mag - v0).
	
	local burn_duration is calc_burn_duration(abs(dv0)).
	if burn_duration = 0 {
		set burn_duration to ves_burn_dur(ship, dv_rem).
	}
	
	
	
	warp_apo(burn_duration / 2 + orient_time).

	print "warped to apo-" + (burn_duration / 2 + orient_time).
	print "burn duration " + burn_duration.

	lock r0 to (ship:position - ship:body:position).
	
	//local h is vcrs(r, ship:velocity:orbit).
	
	lock v_tang to vxcl(r0, ship:velocity:orbit).
	
	lock dir0 to (math_sign(dv0) * v_tang:normalized):direction.
	lock dir  to R(
		dir0:pitch,
		dir0:yaw,
		ship:facing:roll).

	local err is 0.
	
	lock err to mvr_adjust_altitude - alt.

	//set steer to R(dir:pitch, dir:yaw, ship:facing:roll).
	set steer to dir.
	//set steer:roll to ship:facing:roll. 
	
	global lock steering to steer.
	
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
	
	lock mvr_eta to e - burn_duration/2.
	
	if mvr_eta < 0 {
		print "ERROR: missed burn start time".
		print "burn duration/2 " + (burn_duration / 2).
		print "e " + e.
		//print neverset.
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
		// update steering
		set steer to dir.
	
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
		print "    est rem burn " + ves_burn_dur(ship, dv_rem).
		print "    throttle     " + round(th,3).
		print "    v mag 0      " + round(v0,1).
		print "    v mag        " + round(ship:velocity:orbit:mag,1).
		print "    burn dur     " + burn_duration.
		print "    error count  " + error_counter.
		print "    mvr eta 0    " + mvr_eta_0.

		if mode = 10 {
			print "burn in t-" + round(mvr_eta,1).
			
			set v0 to ship:velocity:orbit:mag.
			
			if mvr_eta < 0 {
				set mode to 20.
			}
			if mvr_eta > mvr_eta_0 {
				set mode to 20.
			}
		} else if mode = 20 {
		
			set th to max(0, min(1, ves_burn_dur(ship, dv_rem) / 10 + 0.01)).
	
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
	
	// settings
	local orient_time is 60.
	local precision   is 0.02.
	
	// ==================================================
	// preliminaries
	sas off.
	rcs off.
	lock throttle to 0.
	
	// ==================================================
	// variables
	
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
	
	local burn_duration is calc_burn_duration(abs(dv0)).
	if burn_duration = 0 {
		set burn_duration to ves_burn_dur(ship, dv_rem).
	}

	warp_per(burn_duration/2 + orient_time).
	
	lock v_tan to obt_v_tan_for(ship).
	
	lock dir to (math_sign(dv0) * v_tan:normalized):direction.
	
	local err is 0.
	
	lock err to mvr_adjust_altitude - alt.

	//set steer to R(dir:pitch, dir:yaw, ship:facing:roll).
	set steer to dir.
	global lock steering to steer.
	
	util_wait_orient().

	// ============================================================
	
	lock e to eta:periapsis.
	
	// use argument of periapsis to detect flip
	set aop0 to ship:obt:argumentofperiapsis.
	
	
	// error increasing debounce
	local error_counter is 0.
	
	// initial variable which are updated until burn starts
	local v0        is ship:velocity:orbit:mag.
	local err_min   is abs(err).
	local err_start is err.
	
	local thr is 0.
	lock throttle to th.
	
	lock mvr_eta to e - burn_duration/2.
	
	if mvr_eta < 0 {
		print "ERROR: missed burn start time".
		//print neverset.
	}
	
	set mvr_eta_0 to mvr_eta.
	
	// 10 pre-burn
	// 20 burning
	local mode0 is 10.
	
	until 0 {
		set steer to dir.

		if abs(aop0 - ship:obt:argumentofperiapsis) > 90 {
			print "flip! aop = " + ship:obt:argumentofperiapsis.
			lock alt to periapsis.
			//lock err to alt - mvr_adjust_altitude.
		}

		clearscreen.
		print "MVR ADJUST AT PERIAPSIS".
		print "=======================================".
		print "    mode         " + mode0.
		print "    alt target   " + mvr_adjust_altitude.
		print "    alt          " + alt.
		print "    alt burn     " + alt_burn.
		print "    err          " + err.
		print "    err_min      " + err_min.
		print "    dv           " + dv0.
		print "    ship accel   " + accel.
		print "    est rem burn " + ves_burn_dur(ship, dv_rem).
		print "    v mag 0      " + v0.
		print "    v mag        " + ship:velocity:orbit:mag.
		print "    dv rem       " + dv_rem.
		print "    error count  " + error_counter.
		print "    mvr eta 0    " + mvr_eta_0.
		print "    throttle     " + thr.
	
		if mode0 = 10 {
			print "burn in t-" + round(mvr_eta,1).
			
			set v0 to ship:velocity:orbit:mag.
			
			if mvr_eta < 0 {
				set mode0 to 20.
			}
			if mvr_eta > mvr_eta_0 {
				set mode0 to 20.
			}
		} else if mode0 = 20 {
		
			set thr to math_clamp(ves_burn_dur(ship, dv_rem) / 10 + 0.01, 0, 1).
	
			if abs(err) > abs(err_min) {
				set error_counter to error_counter + 1.
				if error_counter > 5 {
					print "abort: error increasing!".
					break.
				}
			} else {
				set error_counter to 0.
			}
	
			set err_min to min(err_min, abs(err)).

			if 0 {
			if abs(err / ship:obt:semimajoraxis) < precision {
				print "burn complete".
				break.
			}
			}
		} else {
			print "invalid mode " + mode0.
			print neverset.
		}
	
		wait 0.1.
	}
	
	lock throttle to 0.
	print "cooldown".
	wait 5.
}
function mvr_ballistic {
	
	set gc to mun_arch[0].
	
	// velocity components
	
	lock v_surf to vxcl(up:vector, ship:velocity:surface).
	
	// displacement vector from ship to gc
	lock r0 to gc:altitudeposition(mun_arch[1]) - ship:position.
	
	// component tangent to body
	lock t to vxcl(up:vector, r0).
	
	lock ry to r0 - t.
	
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
	
		set thrott to ves_thrott_from_a(ship, a).
		
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
		print "    thrott    " + thrott.
	
		wait 0.1.
	}
}
function mvr_flyover_deorbit {
	parameter mvr_flyover_deorbit_gc.
	
	util_log("mvr_flyover_deorbit " + mvr_flyover_deorbit_gc).
	
	// useful vats
	//lock g to ship:body:mu / (ship:body:radius + altitude)^2.
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
	
	set mvr_flyover_deorbit_highest_peak to get_highest_peak(ship:body).
	
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
	
	local mode is 10.
	
	set d_l_min to 10000000000000.
	
	set counter to 0.
	
	local th is 0.
	lock throttle to th.

	until 0 {
	
		clearscreen.
		print "MVR FLYOVER DEORBIT".
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
			
				set mode to 20.
			}
		} else if mode = 20 {
	
			print "deorbit".
	
			set th to ves_thrott_from_g(ship).

			//set t_l to time:seconds.
			if alt_l < mvr_flyover_deorbit_highest_peak {
				set t_search_dir to -1.
			} else {
				set t_search_dir to 1.
			}
			until 0 {
				//if alt_l < mvr_flyover_deorbit_gc:terrainheight + 2000 {
				if t_search_dir < 0 {
					if alt_l > mvr_flyover_deorbit_highest_peak {
						break.
					}
				} else {
					if alt_l < mvr_flyover_deorbit_highest_peak {
						break.
					}
				}
				set t_l to t_l + t_search_dir.
			}
		
	
			if d_l:mag > d_l_min {
				//set th to ves_thrott_from_a(ship, ves_g(ship) / 2).
				
				// anti-jitter
				set counter to counter + 1.
				if counter = 3 {
					lock throttle to 0.
					break.
				}
			} else {
				// reste count
				set counter to 0.
			}
	
			set d_l_min to min(d_l_min, d_l:mag).
		} else {
			print "invalid mode " + mode.
		}
	
		print "==============================".
		print "    distance to lz " + round(d_l_min,0).
		print "    th             " + th.
	
		wait 0.1.
	}
	set th to 0.
	lock throttle to 0.
	
	print "distance to target when passing".
	print "through " + round(mvr_flyover_deorbit_highest_peak, 0) +
		" altitude is " + round(d_l_min, 0).
	
	// could use time here to adjust for body rotation
}
function mvr_flyover {
	parameter mvr_flyover_gc.

	set warp to 0.
	
	util_log("mvr_flyover " + mvr_flyover_gc).
	
	// useful vats
	lock g to ship:body:mu / (ship:body:radius + altitude)^2.
	//
	
	set mvr_flyover_highest_peak to get_highest_peak(ship:body).
	
	// prereq: low orbit for better accuracy
	circle("low").
	
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
	
	lock dv_rem to 2 * ship:velocity:orbit:mag * sin(inc_change / 2).
	
	
	if abs(inc_change) > 0.1 {
		//local thr0 is 0.
		//lock throttle to thr0.
		lock throttle to 0.

		// ====================================
		// 10 wait for phase of 90
		// 20 inc change burn
	
		local mode to 10.
	
		until 0 {
			set thr0 to ves_thrott_from_burn_dur(ship, dv_rem).

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
	
					set warp to 0.

					set mode to 20.
				} else {
					// other stuff
					if (90 - phase) > 0 or (90 - phase) < -5 {
						set warp to 3.
					} else {
						if not (warp = 0) {
							set warp to 0.
						}
					}
				}
			} else if mode = 20 {
				// status line
	
				// end conditions
				if (inc_change < 0.1) or ((inc_sign * inc_sign_0) < 0) {
	
	
					break.
				}
				
				local steer_vec is (obt_h_for(ship) * math_sign(inc_sign) * -1):normalized.
				
				lock steering to steer_vec:direction.
				
				// orientation
				if 0 {
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
				}

				util_ship_stage_burn().
				
				if vang(steering:vector, ship:facing:vector) > 3 {
					print "change inclination (reorient)".
					//set thr to 0.
					lock throttle to 0.
				} else {
					print "change inclination".
					//local thr0 is ves_thrott_from_burn_dur(ship, dv_rem).
					//lock throttle to ves_thrott_from_burn_dur(ship, dv_rem).
					//lock throttle to thr0.
					lock throttle to 1.
				}
			}
	
			print "===========================================".
			print "    mode       " + mode.
			print "    phase      " + phase.
			print "    inc change " + inc_change.
	
			wait 0.01.
		}
		lock throttle to 0.
		print "cooldown".
		wait 5.
	}
	
	mvr_flyover_deorbit(mvr_flyover_gc).
}
function mvr_safe_periapsis {
	sas off.
	rcs off.
	set warp to 0.

	print "mvr_safe_periapsis".
	
	local safe_altitude to get_alt_safe(ship:body).
	
	if periapsis < safe_altitude {
	
		if ship:verticalspeed > 0 {
		} else {
	
	
			local steer is R(0,0,0).	
			lock steering to steer.

			util_wait_orient().
		
			set thrott to 0.
			lock throttle to thrott.

			until periapsis > safe_altitude or ship:verticalspeed > 0 {
	
				set steer to ves_radialout(ship).
				
				clearscreen.
				print "MVR SAFE PERIAPSIS".
				print "============================".
				print "    periapsis  " + periapsis.
				print "    vert speed " + ship:verticalspeed.
				
				set thrott to 1.
	
				wait 0.1.
			}
			lock throttle to 0.
	
			print "cooldown".
			wait 5.
		}
	
	}
}
function capture_aerobrake {
	set capture_aerobrake_ret to 0.
	
	if not (ship:body:atm:exists) {
		print "body has no atm".
		print neverset.
	}
	
	if ship:verticalspeed > 0 and altitude > ship:body:atm:height {
		print "heading away from atm".
	} else if periapsis > ship:body:atm:height {
		print "periapsis is above atm, do regular capture".
	} else {
		run warp_to_atm.
	
		// 0 captured
		// 1 too deep, 
	
		lock steering to prograde.
	
		until 0 {
			clearscreen.
			print "CAPTURE AEROBRAKE".
			print "=================".
			print "    vs " + ship:verticalspeed.
		
	
			if apoapsis < 0 {
			
			} else {
				if apoapsis < ship:body:atm:height {
					print "WARNING: aerobraking was too deep".
					print "begin emergency landing sequence".
					set capture_aerobrake_ret to 1.
					wait 5.
					break.
				}
			}
	
			if altitude > ship:body:atm:height {
				print "you have left the atm".
				break.
			}
	
		}
	
	}
	
	if capture_aerobrake_ret = 0 {
		// now perform regular capture program
		run capture(0).
	}
}
function burn_to_free_return {
	declare parameter burn_to_free_return_target.
	
	print "WARNING: assumes burning prograde will result in free return".
	
	if not (ship:obt:hasnextpatch) {
		burn_to_encounter(burn_to_free_return_target, 0).
	}
	
	lock steering to prograde.
	util_wait_orient().
	
	set peri_min to 10000000000000000.
	
	until 0 {
		lock throttle to 0.1.
	
		clearscreen.
		print "BURN TO FREE RETURN".
		print "==============================".
		print "    return periapsis " + ship:obt:nextpatch:nextpatch:periapsis.
	
		if ship:obt:nextpatch:nextpatch:periapsis < ship:body:atm:height * 0.8 {
			break.
		}
	
		if ship:obt:nextpatch:nextpatch:periapsis > peri_min {
			break.
		}
	
		set peri_min to min(peri_min, ship:obt:nextpatch:nextpatch:periapsis).
	
		wait 0.1.
	}
	
	lock throttle to 0.
	
	print "cooldown".
	wait 5.
}
function burn_to_encounter {
	parameter b.
	parameter alt0.

	util_log("burn_to_encounter " + b).
	
	set r1 to ship:altitude + ship:body:radius.
	set r2 to b:altitude + ship:body:radius.
	
	//set frac_t to (ship:altitude + burn_to_encounter_body:altitude + 2 * ship:body:radius) / (2 * (ship:body:radius + burn_to_encounter_body:altitude)).
	//set theta to 360 * frac_t.
	//set phi to 180 - theta.
	
	set phi_rad to constant():pi * (1 - (1 / 2 / sqrt(2)) * sqrt(((r1/r2)+1)^3)).
	set phi to 180 / constant():pi * phi_rad.
	
	if phi < 0 {
		//set phi to 360 + phi.
	}
	
	//print "frac_t " + frac_t.
	//print "theta  " + theta.
	print "phi    " + phi.
	
	wait_for_angle(ship, b, ship:body, phi).
	
	lock steering to prograde.
	util_wait_orient().
	
	lock alt_diff_frac to abs((apoapsis - b:altitude) / b:altitude).
	
	set th to 0.
	lock throttle to th.
	until ship:obt:hasnextpatch {
	
		clearscreen.
		print "BURN TO ENCOUNTER".
		print "============================".
		print "    apoapsis  " + apoapsis.
		print "    periapsis " + periapsis.
	
		util_ship_stage_burn().
			
		set th to max(0, min(1, 
			alt_diff_frac * 10 + 0.05
			)).
		
		wait 0.1.
	}
	
	lock throttle to 0.1.
	
	until ship:obt:nextpatch:periapsis > alt0 {
		clearscreen.
		print "ship:obt:nextpatch:periapsis " + ship:obt:nextpatch:periapsis.
		print "target                       " + alt0.
	}
	
	lock throttle to 0.
	
	wait 5.
}
function capture {
	parameter alt.
	
	if alt = 0 {
		set alt to calc_closest_stable_altitude().
	}
	if alt = "low" {
		set alt to get_alt_low().
	}
	
	print "CAPTURE ----------------------------------".
	print "burn to:    " + alt.
	
	set aop to ship:obt:argumentofperiapsis.

	local aop_change is 0.
	
	lock radial to ves_radialout(ship).
	
	// if escape trajectory, burn until capture
	if ship:obt:hasnextpatch {
	
		if periapsis < 0 {
			print "avoid collision with " + ship:body. wait 3.
	
			lock steering to radial.
			util_wait_orient().
	
			lock throttle to 0.1.
			wait until periapsis > alt.
			lock throttle to 0.
			
			print "cooldown".
			wait 5.	
		}
		
		print "perform capture".
		
		set dv to calc_deltav(periapsis, get_soi(ship:body), alt).
		
		if eta:periapsis > 0 { // not yet reached periapsis
			warp_per(calc_burn_duration(abs(dv)) / 2 + 30).
		}
		
		lock steering to retrograde.
		util_wait_orient().
		
		set th to 0.
		lock throttle to th.
		until not (ship:obt:hasnextpatch) {
	
			set th to 1.
	
			clearscreen.
			print "CAPTURE".
			print "================================".
			print "    apoapsis     " + apoapsis.
			print "    th           " + th.
		}
		set th to 0.
		
		print "captured".
	
		set dv to calc_deltav(periapsis, apoapsis, alt).
	
		set v0 to ship:velocity:orbit:mag.
		lock dv_rem to dv - (ship:velocity:orbit:mag - v0).
	
		until (apoapsis < alt) {

			set aop_change to abs(aop - ship:obt:argumentofperiapsis).
			if aop_change > 180 {
				set aop_change to 360 - aop_change.
			}

			if (aop_change > 45) {
				break.
			}

			set th to ves_thrott_from_burn_dur(ship, dv_rem).

			clearscreen.
			print "CAPTURE".
			print "================================".
			print "    apoapsis     " + apoapsis.
			print "    est rem burn " + ves_burn_dur(ship, dv_rem).
			print "    th           " + th.
			print "    dv rem       " + dv_rem.
			print "    aop change   " + aop_change.
		}
		print "burn complete".
		
		lock throttle to 0.
		print "cooldown".
		wait 5.
	}
}
function burn_to {
	declare parameter burn_to_altitude.
	declare parameter precision.
	
	if burn_to_altitude > ship:altitude {
		lock alt to apoapsis.
		
		lock steering to prograde.
		util_wait_orient().
	} else {
		lock alt to periapsis.
	
		lock steering to retrograde.
		util_wait_orient().
	}
	
	lock accel to ship:maxthrust / ship:mass.
	
	set alt_burn to altitude.
	
	local dv0 is calc_deltav(altitude, altitude, burn_to_altitude).
	
	set v0 to ship:velocity:orbit:mag.
	lock dv_rem to dv0 - (ship:velocity:orbit:mag - v0).
	
	lock err to burn_to_altitude - alt.
	
	set err_start to err.
	
	lock frac to abs(err / err_start).
	
	set counter to 0.
	
	set th to 0.
	lock throttle to th.
	
	set err_min to abs(err).
	
	until (err / err_start) < precision {
	
		set th to ves_thrott_from_burn_dur(ship, dv_rem).
		
		clearscreen.
		print "BURN TO".
		print "===================================".
		print "alt target " + burn_to_altitude.
		print "alt        " + alt.
		print "err        " + err.
		print "thortt     " + th.
		
		
		set err_min to min(err_min, abs(err)).
		
		if abs(err) > abs(err_min) {
			print "abort: error increasing!".
			break.
		}
		
		wait 0.1.
	}
	
	lock throttle to 0.
	
	print "cooldown".
	wait 5.
}

