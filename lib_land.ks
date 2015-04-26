function power_land_final {
	sas off.
	rcs on.

	print "power lanf final".
	
	set debug to 0.
	set visual to 0.
	
	// modes
	// 0 default
	// 1 surface speed low: steer up, use rcs for surf speed
	
	// ================================
	
	set down_angle_limit to 135.
	
	set stage_0_alt to 500.
	
	lock accel_max to ship:maxthrust / ship:mass.
	lock g to ship:body:mu / (ship:body:radius + altitude)^2.
	lock twr to accel_max / g.
	lock th_g to g / accel_max.
	
	// ================================
	// terrain_slope estimation
	set slope         to list().
	set slope_n       to 20.
	set slope_size    to 0.
	set slope_index   to 0.
	set slope_sum     to 0.
	
	lock slope_avg  to 0.
	
	when slope_size > slope_n then {
		lock slope_avg  to slope_sum / slope_n.
	}
	
	set terrain_alt to 0.
	
	set i to 0.
	until i = slope_n {
		slope:add(0).
		set i to i + 1.
	}
	
	lock vs to ship:verticalspeed - slope_avg.
	
	// ===================================
	// deploy legs and turn on lights
	when alt:radar < 100 then {
		set legs to true.
		lights on.
	}
	
	// ======================================================
	
	set g to ship:body:mu / ship:body:radius^2.
	
	lock down_angle to vang(ship:facing:vector, up:vector).
	
	lock down_angle_vel to 90 - arctan2(vs, ship:surfacespeed).
	
	lock down_angle_vel_limit_exceeded to abs(down_angle_vel) < down_angle_limit.
	
	// =======================================================
	
	lock v_hori to vxcl(up:vector, ship:velocity:surface).
	//lock v_vert to ship:velocity:surface - v_hori - slope_avg * up:vector.
	lock v_vert to ship:velocity:surface - v_hori.
	
	//lock v to v_hori + v_vert.
	
	lock q to v_vert:mag^2 + 4 * (0.5 * g) * alt:radar.
	
	lock t_to_impact_1 to (-1 * v_vert:mag + sqrt(q)) / a.
	lock t_to_impact_2 to (-1 * v_vert:mag - sqrt(q)) / a.
	
	set vs_target to 0.
	
	// ====================================================
	// target velocity
	
	// vertical 
	
	lock tar_vert to vs_target * up:vector.
	
	// horizontal
	
	lock v_hori_scale to
		min(
			v_hori:mag,
			v_vert:mag / tan(90 - down_angle_limit)
		).
	
	lock tar_hori to v_hori:normalized * v_hori_scale.
	lock tar_hori to v_hori.
	
	lock tar to tar_vert + tar_hori.
	
	// =====================================================
	// burn velocity
	
	lock v_burn_vert_0 to tar_vert - v_vert.
	lock v_burn_hori_0 to tar_hori - v_hori.
	
	// only burn up, not down
	lock v_burn_vert_up to max(0, vdot(up:vector, v_burn_vert_0)).
	
	lock v_burn_vert_1 to up:vector * v_burn_vert_up.
	
	lock v_burn_hori_1 to v_burn_hori_0.
	
	// step used for switching components on and off in loop
	lock v_burn_vert to v_burn_vert_1.
	lock v_burn_hori to v_burn_hori_1.
	
	lock v_burn to v_burn_vert + v_burn_hori.
	
	// ===================================================
	// throttle vector adjusted to give priority to vertical components
	
	set throttle_2_hori_mag to 0.
	set throttle_2_vert_mag to 0.
	
	lock throttle_2_vert to throttle_2_vert_mag * up:vector.
	lock throttle_2_hori to throttle_2_hori_mag * v_burn_hori:normalized.
	
	lock throttle_2 to throttle_2_vert + throttle_2_hori.
	
	// ===================================================
	
	lock P0 to (vs_target - vs).
	
	
	set P0_0 to 0.
	set D0   to 0.
	set I0   to 0.
	
	set Kp0 to 0.10.
	set Ki0 to 0.00.
	set Kd0 to 0.005.
	
	lock thrott0 to Kp0 * P0 + Ki0 * I0 + Kd0 * D0.
	
	
	
	local thrott is 0.
	
	
	// ===========================================
	
	if debug = 0 {
		lock throttle to thrott.
		lock steering to steer.
	}
	
	set t0 to time:seconds.
	
	// ==========================================
	
	// do not let node fall below 45 down angle
	lock down_angle_limited to max(down_angle_vel, down_angle_limit).
	
	lock myretro_vec_vert to -1 * cos(down_angle_limited) * up:vector.
	
	lock myretro_vec_surf to -1 * sin(down_angle_limited) * v_hori:normalized.
	
	lock myretro to (myretro_vec_vert + myretro_vec_surf):direction.
	
	// ==========================================
	
	print "wait for pitch up".
	wait until ship:facing:pitch > 0.
	
	until ship:verticalspeed > -0.1 and alt:radar < 20 {

		if ship:surfacespeed < 0.1 {
			set steer to R(
				up:pitch,
				up:yaw,
				ship:facing:roll).
	
			rcs on.
		} else {
			set steer to R(
				myretro:pitch,
				myretro:yaw,
				ship:facing:roll).
		}
		
	
		set v_burn_mag to v_burn:mag.
			
		// ====================================
		// dont do final descent until surface speed is low
		// "surface speed is low" is judged by ship pitch
	
		if vang(ship:facing:vector, up:vector) > 1 {
			set vs_target to -0.1 * (alt:radar - 50).
		} else {
			set vs_target to -0.1 * (alt:radar - 5) - 0.1.
		}
		
		// ====================================	
	
		if ship:surfacespeed < 0.1 {
			set mode to 1.
			set ship:control:translation to ship:facing:inverse * (-1 * v_hori).
		} else {
			set ship:control:translation to V(0,0,0).
			set mode to 0.
		}
	
		
		set dt to time:seconds - t0.
		set t0 to time:seconds.
		if dt > 0 {
			// ============================
			// terrain slope calc
	
			set slope_sum to slope_sum - slope[slope_index].
	
			// time rate of change of terrain altitude
			set slope[slope_index] to
				((altitude - alt:radar) - terrain_alt) / dt.
			set terrain_alt to altitude - alt:radar.
			
			set slope_sum to slope_sum + slope[slope_index].
	
			set slope_size to slope_size + 1.
	
			set slope_index to slope_index + 1.
			if slope_index = slope_n {
				set slope_index to 0.
			}
	
			// =============================
	
			set I0 to I0 + P0 * dt.
			set D0 to (P0 - P0_0) / dt.
	
			if Ki0 > 0 {
				set I0 to min(1.0/Ki0, max(-1.0/Ki0, I0)).
			}
	
			set P0_0 to P0.
			
			// set thrott according to how much vertical thrust we want
			set thrott to min(1, max(0, thrott0 / cos(down_angle))).
		}
	
		// =====================================================
		// detect severe lz slope and abort.
		if
			vang(ship:facing:vector, up:vector) > 45
			and alt:radar < 50
			and ship:velocity:surface:mag < 1
		{
			print "ABORT LANDING: severse slope".
			set facing_0 to ship:facing.
			lock steer to facing_0.
			lock throttle to th_g.
			wait 3.
			lock throttle to 0.
			print "resume landing sequence".
		}
		
		// =====================================================
		if v_burn_mag = 0 {
	
			//lock steer to R(
			//	up:pitch,
			//	up:yaw,
			//	ship:facing:roll).
			
			set thrott_vert to 0.
			set thrott_hori to 0.
		} else {
			set thrott_vert to v_burn_vert:mag / v_burn_mag * thrott.
			set thrott_hori to v_burn_hori:mag / v_burn_mag * thrott.
		}
	
		clearscreen.
		print "POWER LAND FINAL".
		print "----------------".
		print "    P0                " + P0.
		print "    I0                " + I0.
		print "    D0                " + D0.
		print "    P0 * kp0          " + P0 * kp0.
		print "    I0 * ki0          " + I0 * ki0.
		print "    D0 * kd0          " + D0 * kd0.
		print "    throttle up       " + thrott0.
		print "    throttle          " + thrott.
		print "    throttle_vert     " + thrott_vert.	
		print "    throttle_hori     " + thrott_hori.
		print "    v burn            " + v_burn_mag.
		print "    v burn vert       " + v_burn_vert:mag.
		print "    v burn hori       " + v_burn_hori:mag.
		print "    alt:radar         " + alt:radar.
		print "    slope             " + slope_avg.
		print "    vert speed        " + vs.
		print "    vert speed target " + vs_target.
		print "    hori speed        " + ship:surfacespeed.
		print "    down angle (vel)  " + down_angle_vel.
	
		// =======================================	
	
		if v_burn_mag = 0 {
			set throttle_2_vert_mag to 0.
			set throttle_2_hori_mag to 0.
		} else {
			set throttle_2_vert_mag to v_burn_vert_up / v_burn_mag * thrott.
	
			set b2 to throttle_2_vert_mag^2 - 1.
	
			if b2 < 0 {
				print "throttle vert maxed out".
				set throttle_2_hori_mag to 0.
			} else {
				set throttle_2_hori_mag to
					max(0,
					min(v_burn_hori:mag,
					sqrt(b2)
				)).
			}
		}
	
		// =======================================
		// orientation criteria
	
		if vdot(ship:facing:vector, v_burn_vert) < 0 {
	
			//print "reorienting vert".
			lock v_burn_vert to V(0,0,0).
			
		} else {
			lock v_burn_vert to v_burn_vert_1.
		}
		
		lock ship_facing_hori to vxcl(up:vector, ship:facing:vector).
		
		if vang(ship_facing_hori, v_burn_hori) > 2
		and alt:radar > 100 {
			//print "reorienting hori".
			lock v_burn_hori to V(0,0,0).
		} else {
			lock v_burn_hori to v_burn_hori_1.
		}
		
		// =======================================
	
		lock dot_vert to vdot(ship:facing:vector, myretro_vec_vert).
		lock dot_surf to vdot(ship:facing:vector, myretro_vec_surf).
		
		lock reorienting_vert to (dot_vert < 0).
		lock reorienting_surf to (dot_surf < 0) and (mode = 0).
		
		if reorienting_vert and reorienting_surf {
			print "throttle cut: recorienting vert and surf " + vang(ship:facing:vector, steering:vector).
			lock throttle to 0.
		} else if reorienting_vert {
			print "throttle cut: recorienting vert " + vang(ship:facing:vector, steering:vector).
			lock throttle to 0.
		} else if reorienting_surf {
			print "throttle cut: recorienting surf " + vang(ship:facing:vector, steering:vector).
			lock throttle to 0.
		} else {
			lock throttle to thrott.
		}
	
	
	
		//if vang(ship:facing:vector, steering:vector) > 2 {
		//
		//} else {
		//	lock throttle to thrott.
		//}
	
		// =======================================
	
		if thrott = 1 {
			print "throttle maxed out".
		}
		
		if visual = 1 {
			set vd_v_hori:start  to ship:position.
			set vd_v_hori:vector to v_hori.
		
			set vd_v_vert:start  to ship:position.
			set vd_v_vert:vector to v_vert.
		
			set vd_tar:start  to ship:position.
			set vd_tar:vector to tar.
	
			set vd_steering:start  to ship:position.
			set vd_steering:vector to steer:vector * 10.
	
			set vd_v_burn:start  to ship:position.
			set vd_v_burn:vector to v_burn.
	
			set vd_v_burn_vert:start  to ship:position.
			set vd_v_burn_vert:vector to v_burn_vert_0.
	
			set vd_v_burn_hori:start  to ship:position.
			set vd_v_burn_hori:vector to v_burn_hori_0.
	
			set vd_throttle_2:start  to ship:position.
			set vd_throttle_2:vector to throttle_2 * 10.
		}
	
		wait 0.1.
	}
	
	if debug = 0 {
		lock throttle to 0.
		set ship:control:translation to V(0,0,0).
	}
	
	print "cooldown".
	wait 5.
	print "landing complete".
	
	if visual = 1 {
		set vd_v_hori:show  to false.
		set vd_v_vert:show  to false.
		set vd_v_burn:show  to false.
		set vd_v_burn_vert:show  to false.
		set vd_v_burn_hori:show  to false.
		set vd_throttle_2:show  to false.
		set vd_throttle_2_hori:show  to false.
		set vd_tar:show  to false.
		set vd_steering:show  to false.
	}
}
function power_land_atm {
	
	// preliminaries
	sas off.
	rcs off.
	lock throttle to 0.
	
	set deorbit_body  to sun.
	set deorbit_angle to 90.
	deorbit.
	
	// ===============================================================
	// variables 
	local g is ship:body:mu / ship:body:radius^2.
	lock a to ship:maxthrust / ship:mass * cos(ship:facing:pitch).
	
	lock timetostop to -1.0 * ship:verticalspeed / (a - g).
	
	// ===============================================================
	print "orient retro".
	lock steering to R(
		ship:srfretrograde:pitch,
		ship:srfretrograde:yaw,
		ship:facing:roll).
	
	// ===============================================================
	
	print "wait for descent".
	wait until ship:verticalspeed < 0.
	
	print "wait for atmosphere".
	wait until ship:altitude < ship:body:atm:height.
	
	lock a0 to vang(up:vector, ship:srfretrograde:forevector).
	
	lock throttle to 0.
	
	// ===============================================================
	// do not burn until pitched up
	print "wait for pitch up".
	wait until vdot(ship:facing:vector, up:vector) > 0.
	
	
	set scal1 to 1.0.
	
	//lock timetoterm to () / g.
	
	local term_speed is 0.
	
	lock delvel to 1.
	
	until alt:radar < 2000 {
	
		set term_speed to calc_obt_term_speed(ship).
		
		set timetoterm to (term_speed + ship:verticalspeed) / g.
		
		set disttoterm to (term_speed^2 - ship:verticalspeed^2) / 2 / g.
		
		if delvel < 0.1 {
			// close to term
			set timetoimpact to alt:radar / term_speed.
			set meth to 0.
		} else if alt:radar < disttoterm {
			// not going to reach term
	
			set q to sqrt(ship:verticalspeed^2 + 2.0 * g * alt:radar).
			set t0 to (-1.0 * ship:verticalspeed + q) / -g.
			set t1 to (-1.0 * ship:verticalspeed - q) / -g.
	
			if t0 < 0 {
				set timetoimpact to t1.
			} else if t1 < 0 {
				set timetoimpact to t0.
			} else {
				set timetoimpact to min(t0, t1).
			}
			set meth to 1.
		} else {
			// going to reach term
			set timetoimpact to timetoterm +
				(alt:radar - disttoterm) / ship:termvelocity.
			set meth to 2.
		}
	
		clearscreen.
		print "speed vert " + ship:verticalspeed.
		print "speed term " + term_speed.
		print "radar      " + alt:radar.
		print "timetoterm " + timetoterm.
		print "disttoterm " + disttoterm.
		
		if timetoimpact < (timetostop + 1) {
			print "timetoimpact " + meth + " " + timetoimpact.
			lock throttle to 1.
			wait until ship:verticalspeed > (-0.2 * alt:radar).
			lock throttle to 0.
		}
	
		wait 0.2.
	}
	
	power_land_final().
}
function power_land_no_atm {
	
	set next_stage_altitude to 2000.
	
	if ship:velocity:surface:mag < 0.01 {
		// already landed
	} else {
	
		if alt:radar < next_stage_altitude {
			// already at next stage
		} else {
	
			// ===================================================
			// variables
	
			lock g to ship:body:mu / (ship:altitude + ship:body:radius)^2.
	
			lock a to ship:maxthrust / ship:mass * cos(ship:facing:pitch).
	
			// if in stable orbit
			if periapsis > get_highest_peak(ship:body) {
				//set deorbit_body  to power_land_no_atm_body.
				//set deorbit_angle to power_land_no_atm_angle.
				run deorbit.
			}
	
			lock steering to R(ship:srfretrograde:pitch, ship:srfretrograde:yaw, 180).
			util_wait_orient().
	
			//wait until ship:verticalspeed < 0.
	
	
	
			lock timetostop to -1.0 * ship:verticalspeed / (a - g).
	
			set scal1 to 1.0.
	
			if ship:body:atm:exists {
				lock timetoterm to scal1 * -1.0 * ((-1.0 * ship:termvelocity) - ship:verticalspeed) / g.
				lock disttoterm to -1.0 * (ship:verticalspeed * timetoterm - 0.5 * g * timetoterm^2).
				lock delvel to abs((ship:verticalspeed + ship:termvelocity) / ship:termvelocity).
			} else {
				lock timetoterm to 0.
				lock disttoterm to 0.
				lock delvel to 1.
			}
	
			set counter to 0.
	
	
			//lock v_hori to vxcl(up:vector, ship:velocity:surface).
			//lock v_vert to ship:velocity:surface - v_hori.
	
			lock pitch_vel to arctan2(ship:verticalspeed,  ship:surfacespeed).
	
	
			until alt:radar < next_stage_altitude {
	
				set q to sqrt(ship:verticalspeed^2 + 2.0 * g * alt:radar).
				set t0 to (-1.0 * ship:verticalspeed + q) / -g.
				set t1 to (-1.0 * ship:verticalspeed - q) / -g.
				if t0 < 0 {
				   	set timetoimpact to t1.
				} else if t1 < 0 {
				  	set timetoimpact to t0.
				} else {
				   	set timetoimpact to min(t0, t1).
				}
		
				clearscreen.
				print "POWER LAND NO ATM".
				print "==================================================".
				print "    controled descent to " + round(next_stage_altitude,0).
				print "    highest peak         " + round(get_highest_peak(ship:body),0).
				print "    radar altitude       " + round(alt:radar,0).
				print "    g                    " + round(g,1).
				print "    vert speed           " + ship:verticalspeed.
				print "    surf speed           " + ship:verticalspeed.
				print "    pitch vel            " + pitch_vel.
				print "    time to impact       " + round(timetoimpact,1).
				print "    time to stop         " + round(timetostop,1).
	
				if timetoimpact < (timetostop + 5) {
					print "warning!".
			
					lock throttle to 1.
				} else if altitude < get_highest_peak(ship:body) and pitch_vel > -45 {
					print "reduce horizontal velocity".
					lock throttle to 1.
				} else {
					lock throttle to 0.
				}
				
				wait 0.1.
			}
	
		}
	
		power_land_final().
	}
}
function power_land_arrest_surf_speed {
	sas off.
	lock throttle to 0.
	
	set visual to 0.
	
	if visual = 1 {
	set vec_v_srf to vecdraw().
	set vec_v_srf:show  to true.
	set vec_v_srf:color to white.
	
	set vec_v_hori to vecdraw().
	set vec_v_hori:show  to true.
	set vec_v_hori:color to red.
	}
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	lock v_hori to vxcl(up:vector, ship:velocity:surface).
	
	lock v_vert to ship:velocity:surface - v_hori.
	
	// d can only be negative
	lock d to min(0, vdot(v_vert, up:vector)).
	
	// do not burn downward
	lock v_burn to (v_vert:normalized * d) - v_hori.
	
	lock est_rem_burn to v_burn:mag / accel_max.
	
	lock pitch to arctan2(d, v_hori:mag).
	
	lock steering to R(
		v_burn:direction:pitch,
		v_burn:direction:yaw,
		ship:facing:roll).
	
	set th to 0.
	
	lock throttle to th.
	
	until v_burn:mag < 10 {
	
		run lines_print_and_clear.
		print "POWER LAND ARREST SRF VELOCITY".
		print "=====================================".
		print "    alt:radar  " + alt:radar.
		print "    vert speed "	+ ship:verticalspeed.
		print "    surf speed " + ship:surfacespeed.
		print "    pitch      " + pitch.
		print "    accel max  " + accel_max.
		print "    th         " + th.
	
		if vang(ship:facing:vector, steering:vector) > 1 {
			print "wait for orientation".
			set th to max(0, min(1, est_rem_burn / 2)).
		} else {
			if power_land_arrest_srf_velocity_accel = 0 {
				set th to 1.
			} else {
				set th0 to power_land_arrest_srf_velocity_accel / (accel_max * cos(pitch)).
	
				set th to max(0, min(1,
					min(th0, est_rem_burn / 2)
					)).
			}
		}
	
	
		wait 0.1.
	}
	set th to 0.
	
	lock throttle to 0.
}

function deorbit {
	declare parameter deorbit_body.
	declare parameter deorbit_angle.

	print "DEORBIT ----------------------------------".
	print "body:       " + deorbit_body.
	print "angle:      " + deorbit_angle.

	if ship:body:atm:exists {
		run deorbit_atm.
	} else {
		run deorbit_no_atm.
	}
}
function deorbit_atm {
	declare parameter deorbit_body.
	declare parameter deorbit_angle.

	print "deorbit atm".
	
	set peri_target to ship:body:atm:height * 0.5.
	
	if periapsis > ship:body:atm:height {
	
		if periapsis < (ship:body:radius / 4) {
			circle(periapsis).
		} else {
			circle(ship:body:radius / 4).
		}
	
	
	
		print "periapsis target = " + peri_target.
	
		run wait_for_angle(ship, deorbit_body, ship:body, deorbit_angle).
	
		lock steering to retrograde.
		util_wait_orient().
	
		lock throttle to 1.
		wait until periapsis < peri_target.
		lock throttle to 0.
	
		wait 5.
	
	}
}
function deorbit_no_atm {
	declare parameter deorbit_no_atm_body.
	declare parameter deorbit_no_atm_angle.
	
	print "DEORBIT NO ATM ---------------------------".
	print "body:       " + deorbit_body.
	print "angle:      " + deorbit_angle.
	print "periapsis:  " + periapsis.
	print "apoapsis:   " + apoapsis.
	wait 4.
	
	if periapsis > 10000 {
	
		print "burn to suborbital trajectory".
	
		if periapsis < (ship:body:radius / 4) {
			print "periapsis is below (radius/4)".
			set circle_altitude to periapsis.
			run circle.
		} else {
			print "periapsis is above (radius/4)".
			wait 4.
			set circle_altitude to ship:body:radius / 4.
			run circle.
		}
	
		set peri_target to -1 * ship:altitude.
	
		print "periapsis target = " + peri_target.
	
		set wait_for_angle_body_1    to ship.
		set wait_for_angle_body_2    to deorbit_body.
		set wait_for_angle_body_axis to ship:body.
		set wait_for_angle_angle     to deorbit_angle.
		run wait_for_angle.
	
		lock steering to retrograde.
		run wait_orient.
	
		lock throttle to 1.
		wait until periapsis < peri_target.
		lock throttle to 0.
	
		wait 5.
	}
}
