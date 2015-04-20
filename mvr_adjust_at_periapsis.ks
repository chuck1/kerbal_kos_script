//declare parameter mvr_adjust_altitude.

util_log("mvr_adjust_at_apoapsis " + mvr_adjust_altitude).

// prereq
//run mvr_safe_periapsis.

set precision to 0.02.

// when apoapsis and periapsis are close,
// the locations are unstable.
if abs((apoapsis - periapsis) / periapsis) < precision {
	set burn_to_altitude to mvr_adjust_altitude.
	run burn_to.
}

// ==================================================
// preliminaries
sas off.
rcs off.
lock throttle to 0.

// ==================================================
// variables

lock error_max to max(
	abs((apoapsis  - mvr_adjust_altitude)/mvr_adjust_altitude),
	abs((periapsis - mvr_adjust_altitude)/mvr_adjust_altitude)).

lock accel to ship:maxthrust / ship:mass.




if apoapsis < 0 {
	set mode to 0.
} else if periapsis < 0 {
	set mode to 1.
} else {
	if eta:periapsis < eta:apoapsis {
		set mode to 0.
	} else {
		set mode to 1.
	}
}

// mode = 0
print "approaching periapsis " + periapsis.
lock alt to apoapsis.
set alt_burn to periapsis.


local dv0 is calc_deltav(alt_burn, alt, mvr_adjust_altitude).


set v0 to ship:velocity:orbit:mag.

lock dv_rem to dv0 - (ship:velocity:orbit:mag - v0).

lock est_rem_burn to abs(dv_rem / accel).


util_warp_per(est_rem_burn/2 + 30).

if dv0 < 0 {
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
util_wait_orient().

// ============================================================


lock e to eta:periapsis.



// use argument of periapsis to detect flip
set aop0 to ship:obt:argumentofperiapsis.

when abs(aop0 - ship:obt:argumentofperiapsis) > 90 then {
	print "flip! aop = " + ship:obt:argumentofperiapsis.
	
	lock alt to periapsis.
	set mode to 1.
	
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
	wait until 0.
}

set mvr_eta_0 to mvr_eta.

// 0 pre-burn
// 1 burning
set mvr_adjust_stage to 0.

set err_min   to err.
set err_start to err.

until (err / err_start) < precision {

	clearscreen.
	print "MVR ADJUST AT PERIAPSIS".
	print "=======================================".
	print "    alt target   " + mvr_adjust_altitude.
	print "    alt          " + alt.
	print "    alt burn     " + alt_burn.
	print "    err          " + err.
	print "    err_min      " + err_min.
	print "    dv           " + dv0.
	print "    ship accel   " + accel.
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
	
		if abs(err) > (abs(err_min) + 10) {
			print "abort: error increasing!".
			break.
		}
	}

	wait 0.1.
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
if eta:periapsis < eta:apoapsis {
	set warp_string to "per".
	set warp_sub to 0.		
	run warp.
}
}


