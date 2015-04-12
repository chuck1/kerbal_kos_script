sas off.
rcs on.

set debug to 0.
set visual to 0.

set get_highest_peak_body to ship:body.
run get_highest_peak.

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

// ==================================
if visual = 1 {
	set vd_v_hori to vecdraw().
	set vd_v_hori:show  to true.
	set vd_v_hori:color to green.
	set vd_v_hori:label to "v_hori".

	set vd_v_vert to vecdraw().
	set vd_v_vert:show  to true.
	set vd_v_vert:color to green.
	set vd_v_vert:label to "v_vert".

	set vd_v_burn to vecdraw().
	set vd_v_burn:show  to true.
	set vd_v_burn:color to red.
	set vd_v_burn:label to "v_burn".

	set vd_v_burn_vert to vecdraw().
	set vd_v_burn_vert:show  to true.
	set vd_v_burn_vert:color to red.
	set vd_v_burn_vert:label to "v_burn_vert".

	set vd_v_burn_hori to vecdraw().
	set vd_v_burn_hori:show  to true.
	set vd_v_burn_hori:color to red.
	set vd_v_burn_hori:label to "v_burn_hori".

	set vd_throttle_2 to vecdraw().
	set vd_throttle_2:show  to true.
	set vd_throttle_2:color to white.
	set vd_throttle_2:label to "throttle_2".

	set vd_throttle_2_hori to vecdraw().
	set vd_throttle_2_hori:show  to true.
	set vd_throttle_2_hori:color to white.
	set vd_throttle_2_hori:label to "throttle_2_hori".

	set vd_tar to vecdraw().
	set vd_tar:show  to true.
	set vd_tar:color to blue.
	set vd_tar:label to "tar".

	set vd_steering to vecdraw().
	set vd_steering:show  to true.
	set vd_steering:color to magenta.
	set vd_steering:label to "steering".
}
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

lock v to v_hori + v_vert.

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



set thrott to 0.


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

lock steer to R(
	myretro:pitch,
	myretro:yaw,
	ship:facing:roll).

print "wait for pitch up".
wait until ship:facing:pitch > 0.

when ship:surfacespeed < 0.1 then {
	lock steer to R(
		up:pitch,
		up:yaw,
		ship:facing:roll).

	rcs on.
}



until ship:verticalspeed > -0.1 and alt:radar < 20 {

	set v_burn_mag to v_burn:mag.
		
	// ====================================
	// dont do final descent until surface speed is low
	// "surface speed is low" is judged by ship pitch

	
	if vang(ship:facing:vector, up:vector) > 1 {
		set vs_target to -0.1 * (alt:radar - 50).
	} else {
		set vs_target to -0.1 * alt:radar - 0.1.
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





