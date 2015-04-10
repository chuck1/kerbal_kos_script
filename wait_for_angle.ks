// parameter wait_for_angle_body_1.
// parameter wait_for_angle_body_2.
// parameter wait_for_angle_body_axis.
// parameter wait_for_angle_angle.



lock r1 to (wait_for_angle_body_1:position - wait_for_angle_body_axis:position).
lock r2 to (wait_for_angle_body_2:position - wait_for_angle_body_axis:position).


if wait_for_angle_body_axis = sun {
	// this is for interplanetary calculations

	if ship:body = sun {
		print "ERROR".
		wait until 0.
	}
	if not (ship:body:obt:body = sun) {
		print "ERROR".
		wait until 0.
	}

	lock vsb to ship:body:velocity:orbit - sun:velocity:orbit.
	lock rsb to ship:body:position       - sun:position.

	lock v1m to sqrt(wait_for_angle_body_axis:mu / wait_for_angle_body_1:obt:semimajoraxis).
	lock v2m to sqrt(wait_for_angle_body_axis:mu / wait_for_angle_body_2:obt:semimajoraxis).

	set omega_1 to v1m / r1:mag / constant():pi * 180.
	set omega_2 to v2m / r2:mag / constant():pi * 180.

	set omega_sign to 1.
	
	set d_sign to 1.
} else {
	// this is for use inside a planetary system

	lock v1 to (wait_for_angle_body_1:velocity:orbit - wait_for_angle_body_axis:velocity:orbit).
	lock v2 to (wait_for_angle_body_2:velocity:orbit - wait_for_angle_body_axis:velocity:orbit).

	lock v1m to v1:mag.
	lock v2m to v2:mag.

	lock normal_1 to vcrs(r1,v1).
	lock normal_2 to vcrs(r2,v2).

	set omega_sign to vdot(normal_1, normal_2) / abs(vdot(normal_1, normal_2)).

	lock c to vcrs(r1,r2).

	lock d to vdot(c, normal_1).

	lock d_sign to d / abs(d).
}


set omega_1 to v1m / r1:mag / constant():pi * 180.
set omega_2 to v2m / r2:mag / constant():pi * 180.










if wait_for_angle_angle < 0 {
	set wait_for_angle_angle to wait_for_angle_angle + 360.
}


set a to d_sign * vang(r1,r2).
if a < 0 {
	set a to a + 360.
}

set derror to (omega_1 - omega_2) * omega_sign.

lock error to wait_for_angle_angle - a.


lock eta to error / omega.
if eta < 0 {
	lock eta to -1 * error / omega.
}


//if error < 0 and omega > 0 {
//	lock error to 360 + (a - wait_for_angle_angle).
//}

lock wait_for_angle_e to abs((a - wait_for_angle_angle) / a).

if eta > 120 {

	set warp_time_tspan to (eta - 60).
	run warp_time.

}



set a_0 to abs(a).

until wait_for_angle_e < 0.01 {

	if wait_for_angle_body_axis = sun {
		if abs(a) < a_0 {
			set d_sign to -1 * omega_sign.
		} else {
			set d_sign to  1 * omega_sign.
		}
		set a_0 to abs(a).
	}

	set a to d_sign * vang(r1,r2).
	if a < 0 {
		set a to a + 360.
	}

	set a_0 to abs(a).

	set time_eta to time + eta.
	set time_eta to time_eta - time.
	
	clearscreen.
	print "WAIT FOR ANGLE".
	print "=============================================".
	print "body 1        " + wait_for_angle_body_1.
	print "body 2        " + wait_for_angle_body_2.
	print "body axis     " + wait_for_angle_body_axis.
	print "a_2           " + wait_for_angle_angle.	
	print "a_1           " + a.
	print "a_2 - a_1     " + (wait_for_angle_angle - a).
	print "omega         " + omega.
	print "omega_sign    " + omega_sign.

	//print "sign          " + d_sign.
	print "v1            " + v1m.
	print "v2            " + v2m.
	print "va            " + wait_for_angle_body_axis:velocity:orbit:mag.
	print "r1            " + r1:mag.
	print "r2            " + r2:mag.
	print "omega 1       " + omega_1.
	print "omega 2       " + omega_2.
	
	print "eta           " + eta.
	print "eta           " + time_eta:calendar + " " + time_eta:clock.
	print "eta           " + time_eta:seconds.
	print "diff          " + diff.




	wait 0.1.
}









