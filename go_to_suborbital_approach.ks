declare parameter go_to_suborbital_approach_dest.

set g to ship:body:mu / ship:body:radius^2.

// velocity components

lock v_surf to vxcl(up:vector, ship:velocity:surface).


// displacement vector from ship to gc
lock r to go_to_suborbital_approach_dest[0]:altitudeposition(mun_arch[1]) - ship:position.

// component tangent to body
lock rt to vxcl(up:vector, r).

lock v_surf_z to vxcl(rt, v_surf).

lock ry to r - rt.

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

run get_highest_peak_here.

lock accel_max to ship:maxthrust / ship:mass.

set d_min to go_to_suborbital_approach_dest[0]:distance + 100.

lock pitch to arctan2(ship:verticalspeed, ship:surfacespeed).

set accel_target to 0.8 * accel_max.

lock time_to_arrest_surf_speed to ship:surfacespeed / accel_target.

// 3000 is correction factor
// need to determine cause of overshoot
lock distance_to_arrest_surf_speed to
	ship:surfacespeed * time_to_arrest_surf_speed -
	0.5 * accel_target * time_to_arrest_surf_speed^2 + 3000.

lock time_to_reach to rx:mag / ship:surfacespeed.

lock eta_arrest_burn to (rx:mag - distance_to_arrest_surf_speed) / ship:surfacespeed.

lock a_surf_target to abs(10^2 - ship:surfacespeed^2) / (2 * (rx:mag - 1000)).

lock thrott_surf_target to a_surf_target / accel_max.

lock pitch_max to arccos(max(0, min(1, thrott_surf_target))).

lock pitch_clamped to min(-pitch, pitch_max).


lock go_to_suborbital_approach_dir_v to
	-1 * v_surf:normalized * cos(pitch_clamped) +
	up:vector * sin(pitch_clamped).



set thrott_desired to 0.6.

lock thrott_surf_desired to thrott_desired * cos(pitch).

lock dthrott to thrott_surf_target - thrott_surf_desired.

set thrott_extra to 0.

set kthrott to 0.2.

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

local steer is retrograde.

lock steering to steer.

set mode to "warp".

set thrott to 0.
lock throttle to thrott.
until 0 {
	
	clearscreen.
	print "GO TO SUBORBITAL APPROACH".
	print "=======================================".

	set go_to_suborbital_approach_dir to go_to_suborbital_approach_dir_v:direction.

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
	
		lock steer to (-1 * v_surf_z):direction.

		set thrott to 0.

		if v_surf_z:mag > 0.1 and eta_arrest_burn > 15 {
			set mode to "burn z".
		}
	
		if eta_arrest_burn < 15 {
			set mode to "wait burn x".
		}

	} else if mode = "burn z" {
		lock steer to (-1 * v_surf_z):direction.
	
		if vang(steering:vector, ship:facing:vector) > 1 {
			print "burn to reduce deflection (wait for orient)".
			set thrott to 0.
		} else {
			print "burn to reduce deflection".
			set thrott to max(0, min(1, ((v_surf_z:mag / accel_max) / 5))).
		}
		
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
			//set power_land_arrest_srf_velocity_accel to accel_target.
			//run power_land_arrest_srf_velocity.
			//break.
			set mode to "burn x".
		}
		
		if rt:mag < distance_to_arrest_surf_speed {
			//set power_land_arrest_srf_velocity_accel to accel_target.
			//run power_land_arrest_srf_velocity.
			//break.
			set mode to "burn x".
		}
	} else if mode = "burn x" {

		
		if vang(steering:vector, ship:facing:vector) > 1 {
			print "burn x (wait for orient)".
			set thrott to 0.
		} else {

			if 		((ship:verticalspeed^2 / 2 / alt:radar + g) > (accel_max / 2)) or
					((alt:radar < 1000) and (ship:verticalspeed < 0)) {
				print "burn x (arrest descent)".
				// if ship is decending below alt:radar of 1000
				// arrest descent

				print arrest_descent_accel.
				print arrest_descent_pitch.
				print arrest_descent_steering.

				lock steering to arrest_descent_steering.
				
				set thrott to 1.
			} else {
				if go_to_suborbital_approach_dest[0]:distance > d_min {
					print "burn x (passed target)".
					// passed destination
					set thrott to 1.
				} else {
					print "burn x".

					set thrott_extra to max(0, thrott_extra + dthrott * kthrott).
	
					lock th0 to a_surf_target / (accel_max * cos(pitch_clamped)).
		
					set thrott to max(0, min(1, th0 + thrott_extra)).
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
		
		set thrott to 1.

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
	print "    pitch max                     " + pitch_max.
	print "    pitch clamped                 " + pitch_clamped.
	
	
	set d_min to min(d_min, go_to_suborbital_approach_dest[0]:distance).

	//if altitude < get_highest_peak_ret {
	//	break.
	//}

	wait 0.1.
}

lock throttle to 0.




