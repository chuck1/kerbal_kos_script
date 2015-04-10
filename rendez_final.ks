clearscreen.

lock throttle to 0.
sas off.
rcs on.

print "rendez final".


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
lock steering to (-1 * dp:portfacing:vector):direction.
run wait_orient.


// move in at 0.1 m/s towards target
lock v0 to o:normalized * 0.1.

lock v_burn to v0 - v.

lock P to o.
lock D to v.

set kp to 0.005.
set kd to 0.5.

lock thrust to P * kp - D * kd.

lock ship_thrust to ship:facing:inverse * thrust.

until P:mag < 0.01 and D:mag < 0.01 {

	//print "ship thrust = " + ship_thrust.

	

	// vis
	set vec_thrust:start to ship:position.
	set vec_thrust:vector to thrust * 100.

	set vec_ship_fore:start to ship:position.
	set vec_ship_star:start to ship:position.
	set vec_ship_up:start to ship:position.

	set vec_ship_fore:vector to ship:facing:forevector * 10.
	set vec_ship_star:vector to ship:facing:starvector * 10.
	set vec_ship_up:vector   to ship:facing:upvector * 10.
	
	//set ship:control:fore      to thrust:x * -1.
	//set ship:control:starboard to thrust:y * -1.
	//set ship:control:top       to thrust:z.

	set ship:control:translation to ship_thrust.

	//wait 0.1.
}

set ship:control:translation to V(0,0,0).


set vec_ship_fore:show to false.
set vec_ship_star:show to false.
set vec_ship_up:show to false.
set vec_thrust:show to false.


