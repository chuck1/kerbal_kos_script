//declare parameter burn_to_altitude.
//declare parameter precision.

if burn_to_altitude > ship:altitude {
	lock alt to apoapsis.
	
	lock steering to prograde.
	run wait_orient.
} else {
	lock alt to periapsis.

	lock steering to retrograde.
	run wait_orient.
}

lock accel to ship:maxthrust / ship:mass.

set alt_burn to altitude.

set deltav_alt  to altitude.
set deltav_alt1 to altitude.
set deltav_alt2 to burn_to_altitude.
run deltav.

set v0 to ship:velocity:orbit:mag.
lock dv_rem to dv - (ship:velocity:orbit:mag - v0).
lock est_rem_burn to abs(dv_rem / accel).

set deltav_alt  to alt_burn.
set deltav_alt1 to alt.
set deltav_alt2 to burn_to_altitude.
run deltav.

lock err to burn_to_altitude - alt.

set err_start to err.

lock frac to abs(err / err_start).

set counter to 0.

set th to 0.
lock throttle to th.

//print "alt          " + alt.
//print "target       " + burn_to_altitude.
//print "initial err  " + err.
//print "est rem burn " + est_rem_burn.

set err_min to err.

until (err / err_start) < precision {
	set th to
		max(0,
		min(1,
		min(est_rem_burn / 5, 1)
		)).
	
	run lines_print_and_clear.
	print "BURN TO".
	print "===================================".
	print "alt target " + burn_to_altitude.
	print "alt        " + alt.
	print "err        " + err.
	print "thortt     " + th.
	
	
	set err_min to min(err_min, err).
	
	if err > err_min {
		print "abort: error increasing!".
		break.
	}
	
	wait 0.1.
}

lock throttle to 0.

print "cooldown".
wait 5.



