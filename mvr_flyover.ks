// PARAM mvr_flyover_gc

print "MVR FLYOVER".
wait 2.

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


clearscreen.
print "MVR FLYOVER".
print "    latlng          " + mvr_flyover_gc.
print "    latlng:distance " + mvr_flyover_gc:distance.
print "    latlng:bearing  " + mvr_flyover_gc:bearing.


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

lock est_rem_burn to dv_rem / (ship:maxthrust / ship:mass).

if abs(inc_change) > 0.1 {

	// wait for phase of 90

	until abs(phase - 90) < 1 {
		clearscreen.
		print "wait for phase of 90".
		print "phase " + phase.
		wait 0.01.
	}

	// burn to change inclination

	set inc_sign_0 to inc_sign.

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



	// do inc change burn

	until inc_change < 0.1 {

		clearscreen.
		print "change inclination".
		print "    inc change " + inc_change.

		if vang(steering:vector, ship:facing:vector) > 3 {
			print "reorienting" + vang(steering:vector, ship:facing:vector).
			lock throttle to 0.
		} else {
			lock throttle to (est_rem_burn / 5 + 0.01).
		}


		if (inc_sign * inc_sign_0) < 0 {
			print "inc sign flipped".
			break.
		}
	}

	lock throttle to 0.
	print "cooldown".
	wait 5.
}


// wait for phase of 45

lock steering to R(
	retrograde:pitch,
	retrograde:yaw,
	ship:facing:roll).

run wait_orient.

until abs(phase - 45) < 1 {
	clearscreen.
	print "wait for phase of 45".
	print "phase " + phase.
	wait 0.01.
}

// search for land position

set  t_l to time:seconds.
lock p_l to positionat(ship, t_l).
lock r_l to p_l - ship:body:position.

// horizontal distance to latlng at t_l
lock d_l to vxcl(r_l, p_l - mvr_flyover_gc:position).

lock alt_l to r_l:mag - ship:body:radius.

// find time at which ship passes below highest peak



set d_l_min to 10000000000000.

until 0 {
	lock throttle to th_g.

	set t_l to time:seconds.
	until 0 {
		if alt_l < mvr_flyover_highest_peak {
			break.
		}
		set t_l to t_l + 1.
	}

	if d_l:mag > d_l_min {
		break.
	}

	set d_l_min to min(d_l_min, d_l:mag).
}
lock throttle to 0.

print "distance to target when passing".
print "through " + round(mvr_flyover_highest_peak, 0) +
	" altitude is " + round(d_l_min, 0).

// could use time here to adjust for body rotation

// should be deorbuting now
// wait until actual horizontal distance increases
// or hit landing limit

set d_min to mvr_flyover_gc:distance + 100.

until 0 {
	clearscreen.
	print "wait for closest approach to LZ or".
	print "alt:radar below 2000".
	print "    distance  " + mvr_flyover_gc:distance.
	print "    d min     " + d_min.
	print "    alt:radar " + alt:radar.
	
	if mvr_flyover_gc:distance > d_min {
		run power_land_arrest_srf_velocity.
		break.
	}

	set d_min to min(d_min, mvr_flyover_gc:distance).

	if alt:radar < 2000 {
		break.
	}
}

run power_land_final.







