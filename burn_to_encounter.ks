
util_log("burn_to_encounter " + burn_to_encounter_body).

set r1 to ship:altitude + ship:body:radius.
set r2 to burn_to_encounter_body:altitude + ship:body:radius.

//set frac_t to (ship:altitude + burn_to_encounter_body:altitude + 2 * ship:body:radius) / (2 * (ship:body:radius + burn_to_encounter_body:altitude)).
//set theta to 360 * frac_t.
//set phi to 180 - theta.

set phi_rad to constant():pi * (1 - (1 / 2 / sqrt(2)) * sqrt(((r1/r2)+1)^3)).
set phi to 180 / constant():pi * phi_rad.

if phi < 0 {
	//set phi to 360 + phi.
}

//print "frac_t " + frac_t.
//print "theta  " + theta.
print "phi    " + phi.


set wait_for_angle_body_1    to ship.
set wait_for_angle_body_2    to burn_to_encounter_body.
set wait_for_angle_body_axis to ship:body.
set wait_for_angle_angle to phi.
run wait_for_angle.

lock steering to prograde.
util_wait_orient().

lock alt_diff_frac to abs((apoapsis - burn_to_encounter_body:altitude) / burn_to_encounter_body:altitude).

set th to 0.
lock throttle to th.
until ship:obt:hasnextpatch {

	clearscreen.
	print "BURN TO ENCOUNTER".
	print "============================".
	print "    apoapsis  " + apoapsis.
	print "    periapsis " + periapsis.

	util_ship_stage_burn().
		
	set th to max(0, min(1, 
		alt_diff_frac * 10 + 0.05
		)).
	
	wait 0.1.
}

lock throttle to 0.1.

wait until ship:obt:nextpatch:periapsis > burn_to_encounter_alt.

lock throttle to 0.

wait 5.
