function wait_for_angle {
	parameter wait_for_angle_body_1.
	parameter wait_for_angle_body_2.
	parameter wait_for_angle_body_axis.
	parameter wait_for_angle_angle.
	
	print "wait_for_angle " +
		wait_for_angle_body_1 + " " +
		wait_for_angle_body_2 + " " +
		wait_for_angle_body_axis + " " +
		wait_for_angle_angle.
	
	util_log("wait_for_angle " +
		wait_for_angle_body_1 + " " +
		wait_for_angle_body_2 + " " +
		wait_for_angle_body_axis + " " +
		wait_for_angle_angle).
	
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
			print neverset.
		}
	
		lock vsb to ship:body:velocity:orbit - sun:velocity:orbit.
		lock rsb to ship:body:position       - sun:position.
	
		lock v1m to sqrt(wait_for_angle_body_axis:mu / wait_for_angle_body_1:obt:semimajoraxis).
		lock v2m to sqrt(wait_for_angle_body_axis:mu / wait_for_angle_body_2:obt:semimajoraxis).
	
		set omega_sign to 1.
		
		set d_sign to 1.
	} else {
		// this is for use inside a planetary system
	
		lock v1 to (wait_for_angle_body_1:velocity:orbit - wait_for_angle_body_axis:velocity:orbit).
		lock v2 to (wait_for_angle_body_2:velocity:orbit - wait_for_angle_body_axis:velocity:orbit).
	
		lock v1m to v1:mag.
		lock v2m to v2:mag.
	
		set normal_1 to vcrs(r1,v1).
		set normal_2 to vcrs(r2,v2).
	
		local normal_dot is 0.
	
		if wait_for_angle_body_2 = sun {
			//set normal_2 to v(0,-1,0).
			set normal_dot to -1 * normal_1:y.
		} else {
			set normal_dot to vdot(normal_1, normal_2).
		}
		
		set omega_sign to math_sign(normal_dot).
		
		lock c to vcrs(r1,r2).
	
		lock d to vdot(c, normal_1).
	
		lock d_sign to d / abs(d).
	}
	
	
	
	if	(not (wait_for_angle_body_1 = sun)) and
		(not (wait_for_angle_body_2 = sun)) {
		if		(wait_for_angle_body_1:obt:body = wait_for_angle_body_axis:obt:body) and
				(wait_for_angle_body_2:obt:body = wait_for_angle_body_axis:obt:body) {
			set omega_1 to 360 / wait_for_angle_body_1:obt:period.
			set omega_2 to 360 / wait_for_angle_body_2:obt:period.
		} else {
			set omega_1 to v1m / r1:mag / constant():pi * 180.
			set omega_2 to v2m / r2:mag / constant():pi * 180.
		}
	} else {
		set omega_1 to v1m / r1:mag / constant():pi * 180.
		set omega_2 to v2m / r2:mag / constant():pi * 180.
	}
	
	if wait_for_angle_angle < 0 {
		set wait_for_angle_angle to wait_for_angle_angle + 360.
	}
	
	set a to d_sign * vang(r1,r2).
	
	//if a < 0 {
	//	set a to a + 360.
	//}
	
	set derror to (omega_1 - omega_2) * omega_sign.
	
	lock error to wait_for_angle_angle - a.
	
	
	set eta to (0 - error) / derror.
	if eta < 0 {
		set eta to (360 - error) / derror.
	}
	
	
	lock wait_for_angle_e to abs((a - wait_for_angle_angle) / a).
	
	if eta > 120 {
		warp_time(eta - 60).
	}
	
	
	
	set a_0 to abs(a).
	
	until wait_for_angle_e < 0.01 {
	
		set eta to (0 - error) / derror.
		if eta < 0 {
			set eta to (360 - error) / derror.
		}
	
		if 0 {
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
		}
	
		set a to d_sign * vang(r1,r2).
	
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
		print "error         " + error.
		print "omega         " + derror.
		print "omega_sign    " + omega_sign.
		print "omega 1       " + omega_1.
		print "omega 2       " + omega_2.
		print "eta           " + eta.
	
		wait 0.1.
	}
}
function wait_for_rendez_launch_window {
	until 0 {

		local os1 is obt_struc_ctor_current_for(ship).
		local os2 is obt_struc_ctor_from_obt(obt_at_body(target:obt, ship:body)).

		local nv is obt_node_vec(os1, os2).
		
		local hv1 is obt_h_for(ship).
		local r is obt_r_for(ship).

		local ph is vang(r,nv) * math_sign(vdot(hv1,vcrs(r,nv))).
		
	
		clearscreen.
		print "wait for rendez launch window".
		print "=============================".
		print "    phase    " + ph.
		print "    hv1      " + hv1.
		print "    rv1      " + r.
		print "    nv       " + nv.
	
		if abs(ph) < 0.1 {
			break.
		}
	
		wait 0.01.
	}
}

