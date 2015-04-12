// PARAMETER hover_mode
// PARAMETER hover_dest
// PARAMETER 



sas off.
rcs on.

lock east to vcrs(north:vector, up:vector):direction.

lock v to north:vector * v_north + east:vector * v_east.

lock throttle to 0.

if ship:maxthrust = 0 {
	stage.
}

set hover_pitch_limit to 15.

lock g to ship:body:mu / (ship:body:radius + altitude)^2.

lock accel_max to ship:maxthrust / ship:mass.

lock twr to accel_max / g.

lock v_srf to vectorexclude(up:vector, ship:velocity:surface).




// ===================================================
// altitude control

set kp0 to 0.30 / twr.
set kd0 to 0.50.
set ki0 to 0.01.

set I0 to 0.

set P0 to 0.




lock D0 to 0 - ship:verticalspeed.

lock Y0 to P0 * kp0 + D0 * kd0 + I0 * ki0.

// ==================================================
// alternate altitude control

lock alt_error to P0.

set vs_target to 0.

lock vs_error to max(0, vs_target - ship:verticalspeed).

// ===================================================
// surface speed control


set dP1dt to V(0,0,0).

if hover_hor_mode = "speed" {

	set kp1 to 0.10.
	set kd1 to 0.10.
	set ki1 to 0.

	lock P1 to v - v_srf.

	lock D1 to dP1dt.

} else if hover_hor_mode = "latlong" {

	set kp1 to 20.0.
	set kd1 to  0.25.
	set ki1 to  0.0.

	set P1_mag_0 to 0.
	set dLLEdt to 0.

	lock lat_error  to hover_dest[0]:lat  - latitude.
	lock long_error to hover_dest[0]:lng - longitude.
	
	lock P1 to north:vector * lat_error - east:vector * long_error.

	lock D1 to -1 * v_srf.
}

set P1_0 to V(0,0,0).
set I1   to V(0,0,0).

if hover_hor_mode = "none" {
	lock P1 to V(0,0,0).
	lock D1 to V(0,0,0).
	lock Y1 to V(0,0,0).
} else {
	lock Y1 to P1 * kp1 + D1 * kd1 + I1 * ki1.
}


// ================================================
// user input

on ag1 {
	set I1 to V(0,0,0).
	preserve.
}
on ag2 {
	set hover_alt to hover_alt - 10.
	preserve.
}
on ag3 {
	set hover_alt to hover_alt + 10.
	preserve.
}
on ag4 {
	set hover_lat to hover_lat - .0010.
	preserve.
}
on ag5 {
	set hover_lat to hover_lat + .0010.
	preserve.
}
on ag6 {
	set hover_long to hover_long - .0010.
	preserve.
}
on ag7 {
	set hover_long to hover_long + .0010.
	preserve.
}



// ===================================================
// desired direction


lock pit to 
	min(
		arctan2(Y1:mag, Y0),
		hover_pitch_limit
	).





lock a_dir to vang(up:vector, dir).




set th to 0.

lock throttle to th.

// ========================================================
// vis
set vd_dir to vecdraw().
set vd_dir:show to true.
set vd_dir:color to red.

set vd_y1 to vecdraw().
set vd_y1:show to true.



set t0 to time:seconds.

until 0 {


	set dir to up:vector * cos(pit) + Y1:normalized * sin(pit).






	set dt to time:seconds - t0.
	set t0 to time:seconds.	

	if hover_alt_mode = "agl" {
		lock P0 to hover_alt - alt:radar.
	} else if hover_alt_mode = "asl" {
		if alt:radar < 100 {
			lock P0 to 100 - alt:radar.
		} else {
			lock P0 to (hover_alt - altitude).
		}
	} else {
		print "ERROR invalid mode".
		print neverset.
	}

	if alt_error > 0 {
		set vs_target to sqrt(2 * g * alt_error).
	} else {
		//lock vs_target to -1 * sqrt(2 * g * alt_error).
		set vs_target to -100.
	}

	if alt:radar > 2000 {
		set hover_pitch_limit to 180.
	} else {
		set hover_pitch_limit to 30.
	}

	// =======================================================
	// end conditions
	if hover_hor_mode = "latlong" {
		if abs(P0) < 5 and P1:mag < 5e-4 {
			break.
		}
	} else if hover_hor_mode = "none" {
		if abs(P0) < 1 {
			break.
		}
	}
	
	// =========================================================
	
	lock thrust_ship to ship:facing:inverse * Y1.

	if P1:mag < 0.1 {
		lock steering to R(up:pitch, up:yaw, ship:facing:roll).
	
		set ship:control:translation to thrust_ship.
	} else {
		lock steering to R(dir:direction:pitch, dir:direction:yaw, ship:facing:roll).

		set ship:control:translation to V(0,0,0).
	}
	
	
	
	if dt > 0 {

		set I0 to I0 + P0 * dt.
		if ship:verticalspeed < 0 {
			set I0 to 0.
		}
		if abs(P0 > 100) {
			set I0 to 0.
		}


		set dP1dt to (P1 - P1_0) / dt.
		set P1_0 to P1.

		if hover_hor_mode = "latlong" {
			// start integral control when close
			if P1:mag < 1 {
				set I1 to I1 + P1 * dt.
			}

			set dLLEdt_0 to dLLEdt.
			set dLLEdt to (P1:mag - P1_mag_0) / dt.
			set P1_mag_0 to P1:mag.

			if (dLLEdt_0 * dLLEdt) < 0 {
				// error rate flip
				set I1 to V(0,0,0).
			}
		}

		// pid control
		//set th to Y0.
		// analytical control
		set th to max(0, min(1, (vs_error / 2) / accel_max)).
	}
	
	// ======================================
	// print
	clearscreen.
	print "HOVER".
	print "==================================================".
	
	print "hover alt     = " + hover_alt.
	print "v_srf:mag     = " + v_srf:mag.
	print "vs error      = " + vs_error.
	print "P0            = " + P0.
	print "I0            = " + I0.
	print "D0            = " + D0.
	print "Y0            = " + Y0.
	print "Y1:mag        = " + Y1:mag.
	print "D1:mag        = " + D1:mag.
	print "P1:mag        = " + P1:mag.
	print "I1:mag        = " + I1:mag.
	print "dP1dt:mag     = " + dP1dt:mag.
	print "pit           = " + pit.
	print "pit0          = " + arctan2(Y1:mag, Y0).
	print "sin(pit)      = " + sin(pit).
	print "cos(pit)      = " + cos(pit).
	
	if hover_hor_mode = "latlong" {
	print "lat           = " + latitude.
	print "long          = " + longitude.
	print "lat error     = " + lat_error.
	print "long error    = " + long_error.
	print "dLLEdt        = " + dLLEdt.
	}
	
	// =========================================

	if vang(ship:facing:vector, steering:vector) > 2 and alt:radar > 10 {
		lock throttle to 0.
		print "reorienting".		
	} else {
		lock throttle to th.
	}

	if thrust_ship:mag > 1 {
		print "rcs maxed out".
	}

	//set vd_dir:start to ship:position.
	//set vd_dir:vector to dir * 10.

	//set vd_y1:start to ship:position.
	//set vd_y1:vector to Y1 * 100.

	
}

set ship:control:translation to V(0,0,0).



