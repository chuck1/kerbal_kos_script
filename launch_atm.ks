
run log("launch_atm " + ship:body).

set lines_add_line to "LAUNCH ATM".
run lines_add.
set lines_indent to lines_indent + 1.

if ship:maxthrust = 0 {
	stage.
}

print "launch!".
lock throttle to 0.8.
lock steering to up + R(0,0,180).

if legs {
	set legs to false.
}


if not (ship:body:atm:exists) {
	print "ERROR no atm".
	print neverset.
}

lock east_vec to vcrs(north:vector, up:vector).

set steering_deflection_limit to 15.
lock down_angle_vel to vang(up:vector, ship:velocity:surface).

// with FAR mod, kOS returns approx 3x terminal velocity

lock speed_target to (ship:termvelocity/12).

lock launch_atm_p to speed_target - ship:velocity:surface:mag.
set th to 0.
lock throttle to th.

set launch_atm_kp to 0.01.

lock pres to ship:body:atm:sealevelpressure * ( constant():e ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).

set pres_stage to 0.14.


// modes
// 10 countdown
// 20 leg 1
// 30 grav turn
// 40 coast

set mode to 20.

until 0 {

	run lines_print_and_clear.
	print "======================================".
	print "LAUNCH ATM".
	print "======================================".

	if mode = 20 {
		print "launch".

		set th to launch_atm_p * launch_atm_kp.

		if pres < pres_stage {
			// transition to mode 30

			set altitude_turn_start to altitude.

			lock down_angle_target to
				min(
					0 + ((altitude - altitude_turn_start) / (5 * altitude_turn_start)) * 60,
					60).
			
			
			// steering deflection: angle between velocity and target steering vectors
			// clamp steering delfection
			lock steering_deflection to
				max(
				-steering_deflection_limit,
				min(
				steering_deflection_limit,
				(down_angle_target - down_angle_vel)
				)).
			
			lock down_angle_steering to (steering_deflection + down_angle_vel).
			
			lock steering_vec to up:vector * cos(down_angle_steering) - east_vec * sin(down_angle_steering).
			
			lock steering to R(
				steering_vec:direction:pitch,
				steering_vec:direction:yaw,
				ship:facing:roll).

			set mode to 30.
		}
	} else if mode = 30 {
		print "gravity turn".
	
		if altitude < (ship:body:atm:height - 1000) {		
			set th to launch_atm_p * launch_atm_kp.
		} else {
			set th to 1.
		}

		if apoapsis > launch_altitude {
			// transition to mode 40

			set th to 0.
			lock throttle to 0.

			set mode to 40.
		}
	} else if mode = 40 {
		print "coast out of atm".
		
		if altitude > ship:body:atm:height {
			run util_jettison_fairings.
			break.
		}
	}

	print "======================================".
	if mode = 20 {
	print "    wait for pres       " + pres_stage.
	print "    pres                " + pres.
	}
	if mode < 40 {
	print "    term vel            " + round(ship:termvelocity, 1).
	print "    vel                 " + round(ship:velocity:surface:mag, 1).
	}
	print "    th                  " + th.
	if mode = 30 {
	print "    apoapsis target     " + round(launch_altitude,0).
	print "    apoapsis            " + round(altitude,0).
	print "    down angle vel      " + round(down_angle_vel,1).
	print "    down angle target   " + round(down_angle_target,1).
	print "    steering deflect    " + round(steering_deflection,1).
	print "    down_angle_steering " + round(down_angle_steering,1).
	}

	list engines in el.
	for engine in el {
		if engine:flameout {
			stage.
			break.
		}
	}

	wait 0.1.
}

wait 5.

// cleanup
set lines_indent to lines_indent - 1.


