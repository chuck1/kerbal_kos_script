// PARAM burn_deltav


lock steering to prograde.
run wait_orient.

set v0 to ship:velocity:orbit:mag.

lock dv_rem to burn_deltav - (ship:velocity:orbit:mag - v0).

lock accel to ship:maxthrust / ship:mass.

lock est_rem_burn to abs(dv_rem / accel).

set th to 0.
lock throttle to th.

until dv_rem < 0 {

	set th to max(0, min(1, est_rem_burn / 10 + 0.01)).
	
	clearscreen.
	print "BURN".
	print "====================================".
	print "    v0     " + v0.
	print "    v      " + ship:velocity:orbit:mag.
	print "    dv     " + burn_deltav.
	print "    dv rem " + dv_rem.
	print "    eta    " + est_rem_burn.
	
}

lock throttle to 0.



