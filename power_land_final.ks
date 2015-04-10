sas off.
rcs on.

run get_body_info.

// ================================

set pitch_limit to 45.

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

when shope_size > slope_n then {
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

// ===================================
// deploy legs and turn on lights
when alt:radar < 100 then {
	set legs to true.
	lights on.
}



// ======================================================

set g to ship:body:mu / ship:body:radius^2.

lock pitch to vang(ship:facing:vector, up:vector).

lock pitch_vel to arctan2(vs, ship:surfacespeed).

lock pitch_vel_limit_exceeded to abs(pitch_vel) < pitch_limit.

// =======================================================

// general purpose PID
set Y to 0.

lock v_hori to vxcl(up:vector, ship:velocity:surface).
lock v_vert to ship:velocity:surface - v_hori - slope_avg * up:vector.


lock q to v_vert:mag^2 + 4 * (0.5 * g) * alt:radar.

lock t_to_impact_1 to (-1 * v_vert:mag + sqrt(q)) / a.
lock t_to_impact_2 to (-1 * v_vert:mag - sqrt(q)) / a.



if altitude > body_info[0] {
	lock tar_vert_mag to -0.1 * (alt:radar - body_info[0]).
} else {
	lock tar_vert_mag to -0.1 * alt:radar - 0.5.
}

when altitude < stage_0_alt then {
	lock tar_vert_mag to -0.1 * alt:radar - 0.5.
	preserve.
}



// ====================================================
// target velocity

// vertical 

lock tar_vert to tar_vert_mag * up:vector.

// horizontal

lock v_hori_scale to
	min(
		v_hori:mag,
		v_vert:mag / tan(pitch_limit)
	).

lock tar_hori to v_hori:normalized * v_hori_scale.

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

lock throttle to Y.

lock P to v_burn:mag.

set I to 0.
set D to 0.
set P0 to 0.

set Kp to 0.05.
set Ki to 0.0.
set Kd to 0.06.

lock dthrott to Kp * P + Ki * I + Kd * D.

set thrott to 0.

lock throttle to thrott.

set t0 to time:seconds.

// ==========================================

lock steer to up.

lock steering to (steer:vector + ship:facing:vector):direction.
//lock steering to steer.

print "wait for pitch up".
wait until ship:facing:pitch > 0.

when ship:surfacespeed < 0.1 then {
	lock steering to R(
		up:pitch,
		up:yaw,
		ship:facing:roll).

	rcs on.
}



until ship:verticalspeed > -0.1 and alt:radar < 20 {

	set v_burn_mag to v_burn:mag.
	
	
	
	if abs(pitch_vel) > pitch_limit {
		lock steer to R(
			ship:srfretrograde:pitch,
			ship:srfretrograde:yaw,
			ship:facing:roll).
	} else {
		if v_burn_mag = 0 {
			//lock steer to R(
			//	up:pitch,
			//	up:yaw,
			//	ship:facing:roll).
			lock steer to R(
				ship:srfretrograde:pitch,
				ship:srfretrograde:yaw,
				ship:facing:roll).
		} else {
			lock steer to R(
				v_burn:direction:pitch,
				v_burn:direction:yaw,
				ship:facing:roll).
		}
	}
	
	
	if ship:surfacespeed < 0.1 {
		set ship:control:translation to ship:facing:inverse * (-1 * v_hori).
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

		set I to I + P * dt.
		set D to (P - P0) / dt.

		if Ki > 0 {
			set I to min(1.0/Ki, max(-1.0/Ki, I)).
		}

		set P0 to P.
		
		//set thrott to max(0, min(1, thrott + dthrott)).
		set thrott to max(0, min(1, dthrott)).
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
		lock steering to facing_0.
		lock throttle to th_g.
		wait 3.
		lock throttle to 0.
		print "resume landing sequence".
	}
	
	// =====================================================
	if v_burn_mag = 0 {

		//lock steering to R(
		//	up:pitch,
		//	up:yaw,
		//	ship:facing:roll).
		
		set thrott_vert to 0.
		set thrott_hori to 0.
	} else {
		set thrott_vert to v_burn_vert:mag / v_burn_mag * thrott.
		set thrott_hori to v_burn_hori:mag / v_burn_mag * thrott.
	}
	
	// cut throttle if error is zero and vs is up
	if vs > 0 and v_burn_mag = 0 {
		set thrott to 0.
	}
	

	clearscreen.
	print "POWER LAND FINAL".
	print "----------------".
	print "    P                 " + P.
	print "    I                 " + I.
	print "    D                 " + D.
	print "    P * kp            " + P * kp.
	print "    I * ki            " + I * ki.
	print "    D * kd            " + D * kd.
	print "    dthrottle         " + dthrott.
	print "    throttle          " + thrott.
	print "    throttle_vert     " + thrott_vert.	
	print "    throttle_hori     " + thrott_hori.
	print "    v burn            " + v_burn_mag.
	print "    v burn vert       " + v_burn_vert:mag.
	print "    v burn hori       " + v_burn_hori:mag.
	print "    alt:radar         " + alt:radar.
	print "    vert speed        " + vs.
	print "    vert speed target " + tar_vert_mag.
	print "    hori speed        " + ship:surfacespeed.

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

	if vdot(ship:facing:vector, v_burn_vert) < 0 {

		print "reorienting vert".
		lock v_burn_vert to V(0,0,0).
	} else {
		lock v_burn_vert to v_burn_vert_1.
	}
	
	lock ship_facing_hori to vxcl(up:vector, ship:facing:vector).

	if vang(ship_facing_hori, v_burn_hori) > 2
	and alt:radar > 100 {
		print "reorienting hori".
		lock v_burn_hori to V(0,0,0).
	} else {
		lock v_burn_hori to v_burn_hori_1.
	}
	
	// =======================================

	if thrott = 1 {
		print "throttle maxed out".
	}

	set vd_v_hori:start  to ship:position.
	set vd_v_hori:vector to v_hori.
	
	set vd_v_vert:start  to ship:position.
	set vd_v_vert:vector to v_vert.
	
	set vd_tar:start  to ship:position.
	set vd_tar:vector to tar.

	set vd_steering:start  to ship:position.
	set vd_steering:vector to steering:vector * 10.

	set vd_v_burn:start  to ship:position.
	set vd_v_burn:vector to v_burn.

	set vd_v_burn_vert:start  to ship:position.
	set vd_v_burn_vert:vector to v_burn_vert_0.

	set vd_v_burn_hori:start  to ship:position.
	set vd_v_burn_hori:vector to v_burn_hori_0.

	set vd_throttle_2:start  to ship:position.
	set vd_throttle_2:vector to throttle_2 * 10.
}

lock throttle to 0.


print "cooldown".
wait 5.
print "landing complete".



set vd_v_hori:show  to false.
set vd_v_vert:show  to false.
set vd_v_burn:show  to false.
set vd_v_burn_vert:show  to false.
set vd_v_burn_hori:show  to false.
set vd_throttle_2:show  to false.
set vd_throttle_2_hori:show  to false.
set vd_tar:show  to false.
set vd_steering:show  to false.






