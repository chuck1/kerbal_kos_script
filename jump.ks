// PARAMETER jump_altitude

lock g to ship:body:mu / (ship:altitude + ship:body:radius)^2.

lock alt_error to jump_altitude - altitude.

if alt_error > 0 {
	lock vs_target to sqrt(2 * g * alt_error).
} else {
	//lock vs_target to -1 * sqrt(2 * g * alt_error).
	lock vs_target to -100.
}

lock accel_max to ship:maxthrust / ship:mass.

lock th_g to g / accel_max.

lock throttle to (g + 0.1) / accel_max.

lock steering to R(
	up:pitch,
	up:yaw,
	ship:facing:roll).

util_wait_orient().

lock vs_error to max(0, vs_target - ship:verticalspeed).

until 0 {

	if abs(jump_altitude - altitude) < 1 {
		break.
	}

	clearscreen.
	print "JUMP".
	print "=============================================".
	print "    eta       " + abs(ship:verticalspeed / g).
	print "    alt error " + alt_error.
	print "    vs error  " + vs_error.
	
	lock throttle to max(0, min(1, (vs_error / 2) / accel_max)).
	
}


