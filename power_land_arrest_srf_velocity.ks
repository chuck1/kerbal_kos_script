
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




// cleanup

set power_land_arrest_srf_velocity_accel to 0.


