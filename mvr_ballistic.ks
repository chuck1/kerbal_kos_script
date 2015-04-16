

set gc to mun_arch[0].

lock accel_max to ship:maxthrust / ship:mass.


// velocity components

lock v_surf to vxcl(up:vector, ship:velocity:surface).

// displacement vector from ship to gc
lock r to gc:altitudeposition(mun_arch[1]) - ship:position.

// component tangent to body
lock t to vxcl(up:vector, r).

lock ry to r - t.

// components of tangent that is perpendicular to surface velocity
lock tz to vxcl(v_surf, t).

// components of tangent that is parallel to surface velocity
lock rx to t - tz.

// distances
lock dx to vdot(rx, v_surf:normalized).
lock dy to vdot(ry, up:vector).


lock g to -1 * ship:body:mu / ship:body:radius^2.


until 0 {


	set u0 to ship:surfacespeed.
	set u1 to 0.

	set v0 to ship:verticalspeed.
	set v1 to 0.
	
	set ax to (u1^2 - u0^2) / 2.0 / dx.
	
	set ay to (v1^2 - v0^2) / 2.0 / dy - g.
	
	set a to sqrt(ax^2 + ay^2).

	set theta to arctan2(ay,ax).
	
	lock steering to (v_surf:normalized * cos(theta) + up:vector * sin(theta)):direction.

	set thrott to a / accel_max.
	
	if dx < 0 {
		break.
	}

	clearscreen.
	print "MVR BALLISTIC".
	print "===============================".


	if thrott < 0.75 {
		print "waiting".
		lock throttle to 0.
	} else {
		print "burning".
		lock throttle to thrott.
	}



	print "===============================".
	print "    dx        " + dx.
	print "    dy        " + dy.
	print "    ax        " + ax.
	print "    ay        " + ay.
	print "    a         " + a.
	print "    theta     " + theta.
	print "    accel max " + accel_max.
	print "    thrott    " + thrott.

	wait 0.1.
	
}







