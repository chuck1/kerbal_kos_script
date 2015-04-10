
sas off.
lock throttle to 0.

set vec_v_srf to vecdraw().
set vec_v_srf:show  to true.
set vec_v_srf:color to white.

set vec_v_hori to vecdraw().
set vec_v_hori:show  to true.
set vec_v_hori:color to red.

print "POWER LAND ARREST SRF VELOCITY -----------".

lock accel to ship:maxthrust / ship:mass.

lock v_srf_hori to vxcl(up:vector, ship:velocity:surface).

lock v_srf_vert to ship:velocity:surface - v_srf_hori.

// d can only be negative
lock d to min(0, vdot(v_srf_vert, up:vector)).

// do not burn downward
lock v_burn to (v_srf_vert:normalized * d) - v_srf_hori.

lock est_burn_time to v_burn / accel.



lock steering to R(v_burn:direction:pitch, v_burn:direction:yaw, ship:facing:roll).



set th to 0.

lock throttle to th.

set th to 1.
until v_burn:mag < 10 {
	if vang(ship:facing:vector, steering:vector) > 1 {
		set th to 0.
		print "wait for orientation".
		wait until vang(ship:facing:vector, steering:vector) < 2.
		set th to 1.
	}

	set vec_v_hori:start  to ship:position.
	set vec_v_hori:vector to v_srf_hori.

	set vec_v_srf:start  to ship:position.
	set vec_v_srf:vector to ship:velocity:surface.
}
set th to 0.

lock throttle to 0.







