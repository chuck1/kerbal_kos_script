

set next_stage_altitude to 2000.

if ship:velocity:surface:mag < 0.01 {
	// already landed
} else {

	if alt:radar < next_stage_altitude {
		// already at next stage
	} else {


		// ===================================================
		// variables

		lock g to ship:body:mu / (ship:altitude + ship:body:radius)^2.

		lock a to ship:maxthrust / ship:mass * cos(ship:facing:pitch).

		set get_highest_peak_body to ship:body.
		run get_highest_peak.

		// if in stable orbit
		if periapsis > get_highest_peak_ret {
			//set deorbit_body  to power_land_no_atm_body.
			//set deorbit_angle to power_land_no_atm_angle.
			run deorbit.
		}

		lock steering to R(ship:srfretrograde:pitch, ship:srfretrograde:yaw, 180).
		run wait_orient.

		//wait until ship:verticalspeed < 0.



		lock timetostop to -1.0 * ship:verticalspeed / (a - g).

		set scal1 to 1.0.

		if ship:body:atm:exists {
			lock timetoterm to scal1 * -1.0 * ((-1.0 * ship:termvelocity) - ship:verticalspeed) / g.
			lock disttoterm to -1.0 * (ship:verticalspeed * timetoterm - 0.5 * g * timetoterm^2).
			lock delvel to abs((ship:verticalspeed + ship:termvelocity) / ship:termvelocity).
		} else {
			lock timetoterm to 0.
			lock disttoterm to 0.
			lock delvel to 1.
		}

		set counter to 0.


		//lock v_hori to vxcl(up:vector, ship:velocity:surface).
		//lock v_vert to ship:velocity:surface - v_hori.

		lock pitch_vel to arctan2(ship:verticalspeed,  ship:surfacespeed).


		until alt:radar < next_stage_altitude {

			set q to sqrt(ship:verticalspeed^2 + 2.0 * g * alt:radar).
			set t0 to (-1.0 * ship:verticalspeed + q) / -g.
			set t1 to (-1.0 * ship:verticalspeed - q) / -g.
			if t0 < 0 {
			   	set timetoimpact to t1.
			} else if t1 < 0 {
			  	set timetoimpact to t0.
			} else {
			   	set timetoimpact to min(t0, t1).
			}



	
			clearscreen.
			print "POWER LAND NO ATM".
			print "==================================================".
			print "    controled descent to " + round(next_stage_altitude,0).
			print "    highest peak         " + round(get_highest_peak_ret,0).
			print "    radar altitude       " + round(alt:radar,0).
			print "    g                    " + round(timetoimpact,1).
			print "    vert speed           " + ship:verticalspeed.
			print "    surf speed           " + ship:verticalspeed.
			print "    pitch vel            " + pitch_vel.
			print "    time to impact       " + round(timetoimpact,1).
			print "    time to stop         " + round(timetostop,1).

			if timetoimpact < (timetostop + 5) {
				print "warning!".
		
				lock throttle to 1.
			} else if altitude < get_highest_peak_ret and pitch_vel > -45 {
				print "reduce horizontal velocity".
				lock throttle to 1.
			} else {
				lock throttle to 0.
			}
			
			wait 0.1.
		}

	}


	set power_land_final_mode_hori to "retro".
	run power_land_final.


}



