// parameter mvr_adjust_altitude.

set precision to 0.02.

// when apoapsis and periapsis are close,
// the locations are unstable.
if abs((apoapsis - periapsis) / periapsis) < precision {
	set burn_to_altitude to mvr_adjust_altitude.
	run burn_to.
}

// ==================================================

set altitiude_lst to list().
set altitiude_lst_i      to  0.
set altitiude_lst_n      to 20.
set altitiude_lst_length to  0.
until altitiude_lst_i = altitiude_lst_n {
	altitiude_lst:add(0).
	set altitiude_lst_i to altitiude_lst_i + 1.
}

lock altitiude_lst_avg to 0.
when 
lock altitiude_lst_avg to 0.

// ==================================================
// preliminaries
sas off.
rcs on.
set warp to 0.
lock throttle to 0.

// ==================================================
// variables

lock error_max to max(
	abs((apoapsis  - mvr_adjust_altitude)/mvr_adjust_altitude),
	abs((periapsis - mvr_adjust_altitude)/mvr_adjust_altitude)).

lock accel_max to ship:maxthrust / ship:mass.

// ===========================================
// mode = 1

print "approaching apoapsis " + apoapsis.

lock alt to periapsis.

set alt_burn to apoapsis.


set deltav_alt  to alt_burn.
set deltav_alt1 to alt.
set deltav_alt2 to mvr_adjust_altitude.
run deltav.

set v0 to ship:velocity:orbit:mag.

lock dv_rem to dv - (ship:velocity:orbit:mag - v0).

lock est_rem_burn to abs(dv_rem / accel_max).





set warp_string to "apo".
set warp_sub to est_rem_burn/2 + 30.
run warp.

if dv < 0 {
	lock steering to R(
		retrograde:pitch,
		retrograde:yaw,
		ship:facing:roll).

	lock err to alt - mvr_adjust_altitude.
} else {
	lock steering to R(
		prograde:pitch,
		prograde:yaw,
		ship:facing:roll).

	lock err to mvr_adjust_altitude - alt.
}
run wait_orient.

// ============================================================


lock e to eta:apoapsis.


// use argument of periapsis to detect flip
set aop0 to ship:obt:argumentofperiapsis.


when abs(aop0 - ship:obt:argumentofperiapsis) > 90 then {
	print "flip! aop = " + ship:obt:argumentofperiapsis.
	lock alt to apoapsis.
}



// initial variable which are updated until burn starts
set v0        to ship:velocity:orbit:mag.
set err_min   to err.
set err_start to err.

lock frac to abs(err / err_start).

set counter to 0.

set th to 0.
lock throttle to th.

lock mvr_eta to e - est_rem_burn/2.

if mvr_eta < 0 {
	print "ERROR: missed burn start time".
	print neverset.
}

set mvr_eta_0 to mvr_eta.

// 0 pre-burn
// 1 burning
set mvr_adjust_stage to 0.


until (err / err_start) < precision {
	
	clearscreen.
	print "MVR ADJUST AT APOAPSIS".
	print "=======================================".
	print "    alt target   " + mvr_adjust_altitude.
	print "    alt          " + alt.
	print "    alt burn     " + alt_burn.
	print "    err          " + err.
	print "    err_min      " + err_min.
	print "    dv           " + dv.
	print "    ship accel   " + accel_max.
	print "    est rem burn " + est_rem_burn.
	print "    throttle     " + round(max(0, min(1, est_rem_burn / 10 + 0.01)),3).
	print "    v mag 0      " + v0.
	print "    v mag        " + ship:velocity:orbit:mag.
	print "    dv rem       " + dv_rem.
	print " ".
	
	

	if mvr_eta > 0 and mvr_eta < mvr_eta_0 and mvr_adjust_stage = 0 {
		print "burn in t-" + round(mvr_eta,1).

		set v0        to ship:velocity:orbit:mag.
	} else {
	
		set th to max(0, min(1, est_rem_burn / 10 + 0.01)).

		set err_min to min(err_min, err).
	
		if err > (err_min + 10) {
			print "abort: error increasing!".
			break.
		}
	}
}

lock throttle to 0.
print "burn complete".

// ensure acceleration is over
print "wait for cooldown".
wait 5.


// ===================================================
// ensure burn extrema has passed
if 0 {
print "let extrema pass".
if mode = 0 {
	if eta:periapsis < eta:apoapsis {
		set warp_string to "per".
		set warp_sub to 0.		
		run warp.
	}
} else if mode = 1 {
	if eta:periapsis > eta:apoapsis {
		set warp_string to "apo".
		set warp_sub to 0.
		run warp.
	}
}
}





