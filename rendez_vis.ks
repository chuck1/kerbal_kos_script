clearscreen.

lock throttle to 0.
sas off.
rcs on.

set SHIP:CONTROL:NEUTRALIZE to true.

// vis
set vec_thrust to vecdraw().
set vec_ship_fore to vecdraw().
set vec_ship_star to vecdraw().
set vec_ship_up to vecdraw().

set vec_ship_fore:show to true.
set vec_ship_star:show to true.
set vec_ship_up:show to true.
set vec_thrust:show to true.

set vec_ship_fore:color to red.
set vec_ship_star:color to green.
set vec_ship_up:color to blue.

// get port

for p in target:parts {
	if p:name = "dockingPort2" {
		print p:name.
		set dp to p.
	}
}

lock o_dp to dp:position - ship:position.

lock angle_dp to vang(dp:facing:vector, -1 * o_dp).

lock pf to dp:portfacing:vector.

lock pf_perp to vectorexclude(pf, o_dp):normalized.

// maintain distance from target vessel
lock o to o_dp + pf_perp * 100.



lock v to ship:velocity:orbit - target:velocity:orbit.

// point at docking port
//lock steering to (-1 * dp:portfacing:vector):direction.
//run wait_orient.

// move in at 1 m/s towards target
lock v0 to o / 30.

lock v_burn to v0 - v.

lock P to o.
lock D to v.

set kp to 0.005.
set kd to 0.05.

lock thrust to P * kp - D * kd.

until 0 {

	print "thrust = " + (ship:facing:inverse * thrust).
	
	// vis
	set vec_thrust:start to ship:position.
	set vec_thrust:vector to thrust * 10.

	set vec_ship_fore:start to ship:position.
	set vec_ship_star:start to ship:position.
	set vec_ship_up:start to ship:position.

	set vec_ship_fore:vector to ship:facing:forevector * 10.
	set vec_ship_star:vector to ship:facing:starvector * 10.
	set vec_ship_up:vector to ship:facing:upvector * 10.
	
	
	wait 0.5.
}



set vec_ship_fore:show to false.
set vec_ship_star:show to false.
set vec_ship_up:show to false.
set vec_thrust:show to false.


