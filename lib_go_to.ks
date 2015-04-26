
function go_to_1 {
	parameter go_to_dest.
	
	until 0 {
		
		if go_to_dest[0]:distance < 15000 {
			break.
		}
	
		set hop_mode to "latlng".
		set hop_dest to go_to_dest.
		hop().
	}
	
	
	local sa is list(). sa:add("latlng"). sa:add(go_to_dest).
	hover(0, sa).
	
	power_land_final().
	
	util_log("lat error " + (go_to_dest[0]:lat - latitude)).
	util_log("lng error " + (go_to_dest[0]:lng - longitude)).

	return 0.
}
function go_to {
	parameter go_to_dest.
	//local go_to_dest is get_destination(go_to_dest_string).

	print "go_to " + go_to_dest[3].
	
	util_log("go_to " + go_to_dest[3]).
	
	set go_to_complete to false.
	
	set ship:control:pilotmainthrottle to 0.
	
	if ship:body = go_to_dest[2] {
	
		local obt_type is calc_obt_type(ship).
		
		if (obt_type = "prelaunch") or (obt_type = "landed") {
	
			go_to_1(go_to_dest).
			
			return 0.
		
		} else if obt_type = "suborbit" {
	
			local alt_low is calc_obt_alt_low(go_to_dest[2]).
			
			local soe_low is calc_obt_soe_circle(go_to_dest[2], alt_low).
			
			if calc_obt_soe(ship) > (soe_low + 50000) {
				//check orbital props to see if on a high speed collision course from transfer
				circle("low").
			} else {
				//on an appropriate landing course
	
				go_to_suborbital_approach(go_to_dest).
		
				go_to_1(go_to_dest).
				
				return 0.
			}
	
		} else if (obt_type = "elliptic") or (obt_type = "hyperbolic") {

			circle("low").

		} else if (obt_type = "circular") {
			
			if circle("low") = 0 {
				mvr_flyover(go_to_dest[0]).
			}

		} else {
			print "invalid obt type: " + obt_type.
			return 1.
			print neverset.
		}
	
	} else {
		transfer_to(go_to_dest[2], "low").
	}

	// returning here errors, dont know why
	reboot.
	return 1.
}
function go_to_suborbital_approach {
	parameter go_to_suborbital_approach_dest.
	
	// define vars
	local alt_err_hover is 0.
	local pitch_hover is 0.
	local acc_hover is 0.
	local verticalspeed_hover is 0.


	local g0 is ship:body:mu / ship:body:radius^2.
	
	// velocity components
	
	lock v_surf to vxcl(up:vector, ship:velocity:surface).
	
	
	// displacement vector from ship to gc
	lock r0 to go_to_suborbital_approach_dest[0]:altitudeposition(mun_arch[1]) - ship:position.
	
	// component tangent to body
	lock rt to vxcl(up:vector, r0).
	
	lock v_surf_z to vxcl(rt, v_surf).
	
	lock ry to r0 - rt.
	
	// components of tangent that is perpendicular to surface velocity
	lock rz to vxcl(v_surf, rt).
	
	// components of tangent that is parallel to surface velocity
	lock rx to rt - rz.
	
	// distances
	lock dx to vdot(rx, v_surf:normalized).
	lock dy to vdot(ry, up:vector).
	
	
	// should be deorbuting now
	// wait until actual horizontal distance increases
	// or hit landing limit
	
	//un get_highest_peak_here.
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	set d_min to go_to_suborbital_approach_dest[0]:distance + 100.
	
	// velocity vector pitch
	lock pitch to arctan2(ship:verticalspeed, ship:surfacespeed).


	// =================================
	//local accel_target is 0.8 * accel_max.

	
	lock a_surf_target to abs(10^2 - ship:surfacespeed^2) / (2 * (rx:mag - 1000)).
	
	lock thrott_surf_target to a_surf_target / accel_max.

	// max pitch to maintain desired surface acceleration
	lock pitch_max to arccos(max(0, min(1, thrott_surf_target))).
	
	//lock pitch_clamped to min(-pitch, pitch_max).
	//lock pitch_clamped to min(pitch_hover, pitch_max).
	lock pitch_clamped to pitch_hover.
	
	lock go_to_suborbital_approach_dir_v to
		-1 * v_surf:normalized * cos(pitch_clamped) +
		up:vector * sin(pitch_clamped).
	
	set thrott_desired to 0.6.
	
	lock thrott_surf_desired to thrott_desired * cos(pitch).
	
	lock dthrott to thrott_surf_target - thrott_surf_desired.
	
	set thrott_extra to 0.
	
	set kthrott to 0.2.
	
	// ========================================

	local accel_target is accel_max * cos(pitch_clamped).
	
	lock time_to_arrest_surf_speed to ship:surfacespeed / accel_target.

	// 3000 is correction factor
	// need to determine cause of overshoot
	lock distance_to_arrest_surf_speed to
		ship:surfacespeed * time_to_arrest_surf_speed -
		0.5 * accel_target * time_to_arrest_surf_speed^2 + 5800.
	
	lock time_to_reach to rx:mag / ship:surfacespeed.
	
	lock eta_arrest_burn to (rx:mag - distance_to_arrest_surf_speed) / ship:surfacespeed.

	// ========================================
	// for arresting descent
	
	lock arrest_descent_accel to -1 * ship:verticalspeed / 2.
	
	lock arrest_descent_pitch_sin to min(arrest_descent_accel, accel_max) / accel_max.
	
	lock arrest_descent_pitch to arcsin(arrest_descent_pitch_sin).
	
	lock arrest_descent_steering to (
		up:vector * arrest_descent_pitch_sin +
		v_surf:normalized * -1 * cos(arrest_descent_pitch)
		):direction.
	


	// mode
	// 10 warp
	// 20 wait
	// 30 burn z
	// 40 wait burn x
	// 50 burn x
	
	global steer is retrograde.
	
	lock steering to steer.
	
	local mode is "warp".
	
	set thrott to 0.
	lock throttle to thrott.
	until 0 {
		// ==============================
		// hover: maintain altitude
	
		// desired vertical speed
		
		set alt_err_hover to (5080 - altitude).
		
		if alt_err_hover > 0 {
			set verticalspeed_hover to sqrt(2 * alt_err_hover * ves_g(ship)).
			set acc_hover to max(0, (verticalspeed_hover - ship:verticalspeed) / 1).
		} else {
			set acc_hover to -(ship:verticalspeed^2) / 2 / alt_err_hover + ves_g(ship).
		}
		
		// accel to burn in 2 seconds
		// but only positive
		
		// pitch to maintain target altitude at throttle=1
		set pitch_hover to arcsin(min(1, acc_hover / ves_a_max(ship))).

	
		clearscreen.
		print "GO TO SUBORBITAL APPROACH".
		print "=======================================".
	
		set go_to_suborbital_approach_dir to go_to_suborbital_approach_dir_v:direction.
	
		set accel_to_arrest_descent to (ship:verticalspeed^2 / 2 / alt:radar + ves_g(ship)).

		if mode = "warp" {
			print "warp".
	
			if eta_arrest_burn > 70 {
				if not (warp = 3) {
					set warp to 3.
				}
			} else {
				if not (warp = 0) {
					set warp to 0.
				}
				set mode to "wait".
			}
		} else if mode = "wait" {
			print "wait for closest approach to LZ or altitude limit".
		
			set steer to (-1 * v_surf_z):direction.
	
			set thrott to 0.
	
			if v_surf_z:mag > 0.1 and eta_arrest_burn > 15 {
				set mode to "burn z".
			}
		
			if eta_arrest_burn < 15 {
				set mode to "wait burn x".
			}
	
		} else if mode = "burn z" {
		
			if vang(steering():vector, ship:facing:vector) > 1 {
				print "burn to reduce deflection (wait for orient)".
				set thrott to 0.
			} else {
				print "burn to reduce deflection".
				set thrott to ves_thrott_from_burn_dur(ship, v_surf_z:mag).
			}
	
			set steer to (-1 * v_surf_z):direction.
		
			if eta_arrest_burn < 15 {
				set mode to "wait burn x".
			}
	
			if v_surf_z:mag < 0.01 {
				set mode to "wait".
			}
	
		} else if mode = "wait burn x" {
			print "wait burn x".
	
			set thrott to 0.
	
			//lock steering to ship:srfretrograde.
			set steer to R(
				go_to_suborbital_approach_dir:pitch,
				go_to_suborbital_approach_dir:yaw,
				0).
	
			if go_to_suborbital_approach_dest[0]:distance > d_min {
				set mode to "burn x".
			}
			
			if rt:mag < distance_to_arrest_surf_speed {
				set mode to "burn x".
			}
		} else if mode = "burn x" {

			
			if vang(steering:vector, ship:facing:vector) > 1 {
				print "burn x (wait for orient)".
				set thrott to 0.
			} else {
	
				//if 		(accel_to_arrest_descent > (accel_max / 2)) or
				//		((alt:radar < 2000) and (ship:verticalspeed < 0)) {
				if false {
					print "burn x (arrest descent)".
					// if ship is decending below alt:radar of 1000
					// arrest descent
	
					print arrest_descent_accel.
					print arrest_descent_pitch.
					print arrest_descent_steering.
	
					set steer to arrest_descent_steering.
					
					set thrott to 1.
				} else {

					set steer to R(
						go_to_suborbital_approach_dir:pitch,
						go_to_suborbital_approach_dir:yaw,
						0).

					if go_to_suborbital_approach_dest[0]:distance > d_min {
						print "burn x (passed target)".
						// passed destination
						set thrott to 1.
					} else {
						print "burn x".
	
						set thrott_extra to max(0, thrott_extra + dthrott * kthrott).
		
						lock th0 to a_surf_target / (accel_max * cos(pitch_clamped)).
			
						//set thrott to max(0, min(1, th0 + thrott_extra)).
						set thrott to 1.
						//set thrott to max(0, min(1, th0)).
					}
				}
			}
	
			if rx:mag < 1000 {
				set mode to "burn x (dx:1000 -> 0)".
			}
	
			if ship:velocity:surface:mag < 10 {
				break.
			}
	
		} else if mode = "burn x (dx:1000 -> 0)" {
			print "burn x (dx:1000 -> 0)".
	
			lock steering to ship:srfretrograde.		
			
			set thrott to ves_thrott_from_burn_dur(ship, ship:velocity:surface:mag).

			if ship:velocity:surface:mag < 10 {
				break.
			}
		} else {
			print "not a valid mode: " + mode.
			print neverset.
		}
	
		print "=====================================".
		//print "    phase                         " + phase.
		print "    distance                      " + round(go_to_suborbital_approach_dest[0]:distance,1).
		print "    distance surf                 " + round(rt:mag,1).
		print "    distance x                    " + round(rx:mag,1).
		//print "    deflection angle              " + round(vang(v_surf, rt),2).
		if mode = "burn z" {
		print "    v_surf_z:mag                  " + v_surf_z:mag.
		}
		//print "    d min                         " + d_min.
		//print "    alt:radar                     " + alt:radar.
		//print "    distance to arrest surf speed " + distance_to_arrest_surf_speed.
		//print "    time to arrest surf speed     " + time_to_arrest_surf_speed.
		if
			(mode = "warp") or
			(mode = "wait") or
			(mode = "burn z") or
			(mode = "wait burn x") {
		print "    eta arrest burn               " + eta_arrest_burn.
		}
		print "    a surf target                 " + a_surf_target.
		print "    thrott surf target            " + (a_surf_target / accel_max).
		print "    dthrott                       " + dthrott.
		print "    thrott_extra                  " + thrott_extra.
		print "    thrott                        " + thrott.
		print "    pitch                         " + pitch.
		print "    pitch hover                   " + pitch_hover.
		print "    pitch max                     " + pitch_max.
		print "    pitch clamped                 " + pitch_clamped.
		print "    accel_to_arrest_descent       " + accel_to_arrest_descent.
		print "    alt err hover                 " + alt_err_hover.
		
		set d_min to min(d_min, go_to_suborbital_approach_dest[0]:distance).
	
		//if altitude < get_highest_peak_ret {
		//	break.
		//}
	
		wait 0.1.
	}
	
	lock throttle to 0.
}
function hop {
	// PARAMETER hop_mode
	// mode = "vector"
	// PARAMETER hop_d
	// PARAMETER hop_north
	// PARAMETER hop_east
	// mode = "latlong"
	// PARAMETER hop_dest
	
	
	if hop_mode = "latlng" {
		jump(get_highest_peak(ship:body)).
	} else if hop_mode = "vector" {
	} else {
	}
	
	rcs on.
	
	// ==================================================
	// visualization
	
	set vec_hop_dir to vecdraw().
	set vec_hop_dir:show to true.
	
	// ==================================================
	// general variables
	
	lock east_v to vcrs(north:vector, up:vector).
	
	lock hop_g to ship:body:mu
		/ (ship:body:radius + ship:altitude)^2.
	
	
	local hop_hor_dir is V(0,0,0).
	
	// =================================================
	
	if hop_mode = "latlng" {
		//set calc_latlong_to_vector_lat  to hop_dest[0].
		//set calc_latlong_to_vector_long to hop_dest[1].
		//set calc_latlong_to_vector_alt  to get_highest_peak_ret.
		//un calc_latlong_to_vector.
	
		//set hop_hor_dir to heading(calc_latlong_to_vector_brng, 0):vector.
		
		set hop_hor_dir to heading(hop_dest[0]:heading, 0):vector.
	
		run calc_suborbital(hop_dest[0]:distance / 2, hop_dest[1], ship:body:radius / 20).
		
		set hop_pitch to calc_suborbital_pitch1.
	
		set hop_v_mag to sqrt(calc_suborbital_v1r^2 + calc_suborbital_v1t^2).
	
	} else if hop_mode = "vector" {
	
		set hop_pitch to 45.
	
		set hop_hor_dir to (north:vector * hop_north - east_v * hop_east):normalized.
		
		set hop_v_mag to
			sqrt(hop_d * hop_g
			/ (2 * cos(hop_theta) * hop_sin)).
	} else {
		print "invalid mode " + hop_mode.
		print neverset.
	}
	
	set hop_sin to sin(hop_pitch).
	set hop_cos to cos(hop_pitch).
	
	// ==================================================
	
	
	
	lock hop_t to 2 * hop_v_mag * hop_sin / hop_g.
	
	set hop_burn_time_limit to time:seconds + (hop_t * 0.2).
	
	lock steering to R(up:pitch,
		up:yaw, ship:facing:roll).
	
	lock throttle to 1.
	wait 1.
	lock throttle to 0.
	
	lock hop_dir to hop_hor_dir * hop_cos + up:vector * hop_sin.
	
	lock hop_v to hop_dir * hop_v_mag.
	
	lock hop_v_burn to hop_v - ship:velocity:surface.
	
	lock steering to R(
		hop_v_burn:direction:pitch,
		hop_v_burn:direction:yaw,
		ship:facing:roll).
	
	lock throttle to 1.
	
	rcs on.
	
	until 0 {
	
		if ship:velocity:surface:mag > hop_v_mag {
			print "vel mag exceeded".
			break.
		}
		if time:seconds > hop_burn_time_limit {
			print "time limit exceeded".
			//wait 3.
			//break.
		}
	
		if hop_v_burn:mag < 10 {
			set ship:control:translation to ship:facing:inverse * hop_v_burn:normalized.
		}
	
		clearscreen.
		print "HOP".
		print "---".
		print "    burn hop_v_burn:mag " + hop_v_burn:mag.
	
		if vang(ship:facing:vector, steering:vector) > 1 {
			lock throttle to 0.	
			print "reorienting".
		} else {
			lock throttle to 1.
		}
		
		set vec_hop_dir:start  to ship:position.
		set vec_hop_dir:vector to hop_dir * 10.
	}
	
	set ship:control:translation to V(0,0,0).
	
	lock throttle to 0.
	
	power_land_no_atm().
}
function jump {
	parameter jump_altitude.
	
	lock g to ship:body:mu / (ship:altitude + ship:body:radius)^2.
	
	lock alt_error to jump_altitude - altitude.
	
	if alt_error > 0 {
		lock vs_target to sqrt(2 * g * alt_error).
	} else {
		//lock vs_target to -1 * sqrt(2 * g * alt_error).
		lock vs_target to -100.
	}
	
	lock accel_max to ship:maxthrust / ship:mass.
	
	lock th_g to g / accel_max.
	
	lock throttle to (g + 0.1) / accel_max.
	
	lock steering to R(
		up:pitch,
		up:yaw,
		ship:facing:roll).
	
	util_wait_orient().
	
	lock vs_error to max(0, vs_target - ship:verticalspeed).
	
	until 0 {
	
		if abs(jump_altitude - altitude) < 1 {
			break.
		}
	
		clearscreen.
		print "JUMP".
		print "=============================================".
		print "    eta       " + abs(ship:verticalspeed / g).
		print "    alt error " + alt_error.
		print "    vs error  " + vs_error.
		
		lock throttle to max(0, min(1, (vs_error / 2) / accel_max)).
		
	}
}

//print "loaded library go_to".


