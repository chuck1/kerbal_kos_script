clearscreen.

rcs off.

print "rendezvous approach 2".

// ==========================================

lock o_target to target:position - ship:position.

lock o to o_target.


for p in target:parts {
	if p:name = "dockingPort2" {
		print p:name.
		set dp to p.
		break.
	}
}

// ==========================================
// determine desired position
lock o_dp to dp:position - ship:position.

lock angle_dp to vang(dp:facing:vector, -1 * o_dp).

lock pf to dp:portfacing:vector.

lock pf_perp to vectorexclude(o_dp, pf):normalized.

// maintain distance from target vessel
lock o to o_dp + pf_perp * 200.


// until dp is facing the ship
when angle_dp < 90 then {
	
	print "docking port is in view".
	
	// aim for 100 m off dockingport
	lock o to o_dp + (pf * 200).
}

// ==========================================
// vis

set vec_o to vecdraw().
set vec_o_dp to vecdraw().
set vec_pf to vecdraw().
set vec_pf_perp to vecdraw().
set vec_v to vecdraw().

set vec_o:show to true.
set vec_o_dp:show to true.
set vec_pf:show to true.
set vec_pf_perp:show to true.
set vec_v:show to true.

// ==========================================

lock v to ship:velocity:orbit - target:velocity:orbit.

// positive indicates moving toward target
lock d to vdot(o,v).

// velocity component perpendicular to position vector
lock v_perp to vectorexclude(v,o_dp).

lock accel_max to ship:maxthrust / ship:mass.

// set v

// goal is to reach target in 60 seconds
lock v0 to o / 30.

lock v_burn to v0 - v.

lock burn_time_max to v_burn:mag / accel_max.

// desired accel is accel needed for 1 second burn
lock accel to v_burn:mag / 1.

lock th0 to accel / accel_max.


lock steering to v_burn:direction.

// make sure steering keeps up
when vang(steering:vector, ship:facing:vector) > 2 then {
	lock throttle to 0.
	preserve.
}
when vang(steering:vector, ship:facing:vector) < 2 then {
	lock throttle to th.
	preserve.
}

until o:mag < 20 {

	
	set vec_o:start to ship:position.
	set vec_o:vector to o.
	set vec_o_dp:start to ship:position.
	set vec_o_dp:vector to o_dp.
	set vec_pf:start to dp:position.
	set vec_pf:vector to pf * 200.
	set vec_pf_perp:start to dp:position.
	set vec_pf_perp:vector to pf_perp * 200.
	set vec_v:start to ship:position.
	set vec_v:vector to v * 10.

	
	// wait until significant burn is needed
	until (v_burn:mag / v:mag) > 0.1 {
		
		print "wait for significant burn".
		print "o:mag      = " + o:mag.
		print "v_burn:mag = " + v_burn:mag.

		set vec_o:start to ship:position.
		set vec_o:vector to o.
		set vec_o_dp:start to ship:position.
		set vec_o_dp:vector to o_dp.
		set vec_pf:start to dp:position.
		set vec_pf:vector to pf * 200.
		set vec_pf_perp:start to dp:position.
		set vec_pf_perp:vector to pf_perp * 200.
		set vec_v:start to ship:position.
		set vec_v:vector to v * 10.
	}

	// burn
	until v_burn:mag < 0.1 or o:mag < 20 {
		set th to max(0.01, min(1, th0)).
		lock throttle to th.

		print "burning".
		print "o:mag      = " + o:mag.
		print "v_burn:mag = " + v_burn:mag.

		set vec_o:start to ship:position.
		set vec_o:vector to o.
		set vec_o_dp:start to ship:position.
		set vec_o_dp:vector to o_dp.
		set vec_pf:start to dp:position.
		set vec_pf:vector to pf * 200.
		set vec_pf_perp:start to dp:position.
		set vec_pf_perp:vector to pf_perp * 200.
		set vec_v:start to ship:position.
		set vec_v:vector to v * 10.
	}
	lock throttle to 0.
	set th to 0.
}	

set vec_o:show to false.
set vec_o_dp:show to false.
set vec_pf:show to false.
set vec_pf_perp:show to false.
set vec_v:show to false.


