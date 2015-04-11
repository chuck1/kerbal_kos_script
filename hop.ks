// PARAMETER hop_mode
// mode = "vector"
// PARAMETER hop_d
// PARAMETER hop_north
// PARAMETER hop_east
// mode = "latlong"
// PARAMETER hop_dest


set get_highest_peak_body to ship:body.
run get_highest_peak.


if hop_mode = "latlong" {
	set jump_altitude to get_highest_peak_ret.
	run jump.
}

rcs on.

// ==================================================
// visualization

set vec_hop_dir to vecdraw().
set vec_hop_dir:show to true.

// ==================================================
// general variables

lock east_v to vcrs(north:vector, up:vector).

lock accel to ship:maxthrust / ship:mass.

lock hop_g to ship:body:mu
	/ (ship:body:radius + ship:altitude)^2.




// =================================================

if hop_mode = "latlong" {
	set calc_latlong_to_vector_lat  to hop_dest[0].
	set calc_latlong_to_vector_long to hop_dest[1].
	set calc_latlong_to_vector_alt  to get_highest_peak_ret.
	run calc_latlong_to_vector.

	set hop_hor_dir to heading(calc_latlong_to_vector_brng, 0):vector.

	set calc_suborbital_alt to hop_dest[2].
	set calc_suborbital_apo to ship:body:radius / 20.
	set calc_suborbital_l to (calc_latlong_to_vector_vec_distance / 2).
	run calc_suborbital.
	
	set hop_pitch to calc_suborbital_pitch1.

	set hop_v_mag to sqrt(calc_suborbital_v1r^2 + calc_suborbital_v1t^2).

} else if hop_mode = "vector" {

	set hop_pitch to 45.

	set hop_hor_dir to (north:vector * hop_north - east_v * hop_east):normalized.
	
	set hop_v_mag to
		sqrt(hop_d * hop_g
		/ (2 * cos(hop_theta) * hop_sin)).
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

set power_land_final_mode_hori to "none".
run power_land_no_atm.




