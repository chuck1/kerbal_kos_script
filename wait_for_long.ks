// PARAM wait_for_long_long

set circle_altitude to apoapsis.
run circle.





lock h to vcrs(
	ship:position - ship:body:position,
	ship:velocity:orbit - ship:body:velocity:orbit).


lock d to vdot(h, V(0,-1,0)).

lock d_sign to d / abs(d).

lock omega to d_sign * 360 / ship:obt:period.




	set error to wait_for_long_long - longitude.
	if error < 0 {
		set error to 360 + wait_for_long_long - longitude.
	}

	set eta to error / omega.




if eta > 60 {
	set warp_time_tspan to eta.
	run warp_time.
}

until error < 1 {
	
	set error to wait_for_long_long - longitude.
	if error < 0 {
		set error to 360 + wait_for_long_long - longitude.
	}

	set eta to error / omega.
	
	
	clearscreen.
	print "WAIT FOR LONGITUDE".
	print "============================".
	print "lng current     " + longitude.
	print "lng target      " + wait_for_long_long.
	print "error           " + error.
	print "omega           " + omega.
	print "eta             " + eta.

	print "h " + h.

	wait 0.01.
}






