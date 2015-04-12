
if ship:maxthrust = 0 {
	stage.
}

set add_line_line to "LAUNCH ATM".
run add_line.
set lines_indent to lines_indent + 1.

print "launch!".
lock throttle to 0.8.
lock steering to up + R(0,0,180).



if legs {
	set legs to false.
}

when stage:liquidfuel < 0.001 then {
    stage.
    preserve.
}

if not (ship:body:atm:exists) {
	print "ERROR no atm".
	print neverset.
}

lock east_vec to vcrs(north:vector, up:vector).


// with FAR mod, kOS returns approx 3x terminal velocity

lock speed_target to (ship:termvelocity/12).

lock P to speed_target - ship:velocity:surface:mag.
set th to 0.
lock throttle to th.

set kd to 0.01.

lock pres to ship:body:atm:sealevelpressure * ( constant():e ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).

set pres_stage to 0.14.

until pres < pres_stage {
	set th to P * kd.
	
	clearscreen.
	run print_lines.
	print "======================================".
	print "LAUNCH ATM".
	print "======================================".
	print "    wait for pres " + pres_stage.
	print "    pres          " + pres.
	print "    term vel      " + round(ship:termvelocity, 1).
	print "    vel           " + round(ship:velocity:surface:mag, 1).
	print "    th            " + th.

	list engines in el.
	for engine in el {
		if engine:flameout {
			stage.
			break.
		}
	}

	wait 0.1.
}
set altitude_turn_start to altitude.

print "gravity turn".

lock down_angle_target to min(0 + ((altitude - altitude_turn_start) / (5 * altitude_turn_start)) * 60, 60).

lock down_angle_vel to vang(up:vector, ship:velocity:surface).

set steering_deflection_limit to 15.

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

until apoapsis > launch_altitude {
	if altitude < (ship:body:atm:height - 1000) {		
		set th to P * kd.
	} else {
		set th to 1.
	}

	clearscreen.
	run print_lines.
	print "======================================".
	print "LAUNCH ATM".
	print "======================================".
	print "    pres                " + pres.
	print "    th                  " + th.
	
	print "    down angle vel      " + round(down_angle_vel,1).
	print "    down angle target   " + round(down_angle_target,1).
	print "    steering deflect    " + round(steering_deflection,1).
	print "    down_angle_steering " + round(down_angle_steering,1).

	print "    burn to apoapsis of " + round(launch_altitude,0).

	list engines in el.
	for engine in el {
		if engine:flameout {
			stage.
			break.
		}
	}

	wait 0.1.
}

print "coast".
lock throttle to 0.
wait 5.




