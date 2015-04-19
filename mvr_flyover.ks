// PARAM mvr_flyover_gc

util_log("mvr_flyover " + mvr_flyover_gc).

set lines_add_line to "MVR FLYOVER " + ship:body + " " + mvr_flyover_gc.
run lines_add.
set lines_indent to lines_indent + 1.

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



if abs(inc_change) > 0.1 {

	// ====================================
	// 10 wait for phase of 90
	// 20 inc change burn

	set mode to 10.


	until 0 {

		run lines_print_and_clear.
		print "MVR FLYOVER".
		print "===========================================".
	
		if mode = 10 {
			// status line
			print "wait for phase of 90".

			// end condition
			if abs(phase - 90) < 1 {
				// transition to mode 1

				set inc_sign_0 to inc_sign.

				set mode to 20.
			}

			// other stuff
			if (90 - phase) > 0 or (90 - phase) < -5 {
				set warp to 2.
			} else {
				set warp to 0.
			}
		} else if mode = 20 {
			// status line

			// end conditions
			if (inc_change < 0.1) or ((inc_sign * inc_sign_0) < 0) {

				lock throttle to 0.
				print "cooldown".
				wait 5.

				break.
			}
			
			// orientation
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

			// other stuff
			if accel_max > 0 {
				set est_rem_burn to dv_rem / accel_max.
			} else {
				stage.
				wait 1.
				set est_rem_burn to 0.
			}

			if vang(steering:vector, ship:facing:vector) > 3 {
				print "change inclination (reorient)".
				lock throttle to 0.
			} else {
				print "change inclination".
				lock throttle to ((est_rem_burn / 5) + 0.01).
			}
		}

		print "===========================================".
		print "    phase      " + phase.
		print "    inc change " + inc_change.

		wait 0.1.
	}

}

set mvr_flyover_deorbit_gc to mvr_flyover_gc.
run mvr_flyover_deorbit.


// cleanup
set lines_indent to lines_indent - 1.




