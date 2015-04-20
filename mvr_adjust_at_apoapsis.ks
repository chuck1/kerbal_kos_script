// parameter mvr_adjust_altitude.
print "mvr_adjust_at_apoapsis " + mvr_adjust_altitude.

util_log("mvr_adjust_at_apoapsis " + mvr_adjust_altitude).

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
set altitiude_lst_sum    to  0.
until altitiude_lst_i = altitiude_lst_n {
	altitiude_lst:add(0).
	set altitiude_lst_i to altitiude_lst_i + 1.
}

lock altitiude_lst_avg to 0.
when altitiude_lst_length > altitiude_lst_n then {
	lock altitiude_lst_avg to altitiude_lst_sum / altitiude_lst_n.
}

// ==================================================
// preliminaries
sas off.
set warp to 0.
lock throttle to 0.

// ==================================================
// variables

lock error_max to max(
	abs((apoapsis  - mvr_adjust_altitude)/mvr_adjust_altitude),
	abs((periapsis - mvr_adjust_altitude)/mvr_adjust_altitude)).

set accel_max to ship:maxthrust / ship:mass.
until accel_max > 0 {
	stage.
	set accel_max to ship:maxthrust / ship:mass.
}


// ===========================================
// mode = 1

print "approaching apoapsis " + apoapsis.

lock alt to periapsis.

set alt_burn to apoapsis.


local dv0 is calc_deltav(alt_burn, alt, mvr_adjust_altitude).

set v0 to ship:velocity:orbit:mag.

lock dv_rem to dv0 - (ship:velocity:orbit:mag - v0).

set est_rem_burn to abs(dv_rem / accel_max).

local burn_duration is calc_burn_duration(abs(dv)).
if burn_duration = 0 {
	set burn_duration to est_rem_burn.
}

util_warp_apo(burn_duration / 2 + 30).

local r is (ship:position - ship:body:position).

//local h is vcrs(r, ship:velocity:orbit).

local v_tang is vxcl(r, ship:velocity:orbit).

local myprograde   is (     v_tang:normalized):direction.
local myretrograde is (-1 * v_tang:normalized):direction.

local dir is (math_sign(dv) * v_tang:normalized):direction.

local err is 0.

lock err to mvr_adjust_altitude - alt.

global lock steering to R(
	dir:pitch,
	dir:yaw,
	ship:facing:roll).


if 0 {
if dv < 0 {
	global lock steering to R(
		myretrograde:pitch,
		myretrograde:yaw,
		ship:facing:roll).

	lock err to alt - mvr_adjust_altitude.
} else {
	global lock steering to R(
		myprograde:pitch,
		myprograde:yaw,
		ship:facing:roll).

	
}

//wait until vang(steering:vector, ship:facing:vector) < 1.
}
util_wait_orient().


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
declare local err_min   is err.
set err_start to err.

//lock mvr_eta to e - est_rem_burn/2.
lock mvr_eta to e - burn_duration/2.

if mvr_eta < 0 {
	print "ERROR: missed burn start time".
	print neverset.
}

set mvr_eta_0 to mvr_eta.
wait 0.001.

// mode
// 10 pre-burn
// 20 burning

local mode is 10.

// loop

set th to 0.
lock throttle to th.

//until (err / err_start) < precision {
until 0 {

	set accel_max to ship:maxthrust / ship:mass.
	until accel_max > 0 {
		stage.
		set accel_max to ship:maxthrust / ship:mass.
		
	}
	
	set est_rem_burn to abs(dv_rem / accel_max).
	
	util_ship_stage_burn().

	clearscreen.
	print "MVR ADJUST AT APOAPSIS".
	print "=======================================".
	print "    alt target   " + mvr_adjust_altitude.
	print "    apoapsis     " + apoapsis.
	print "    periapsis    " + periapsis.
	print "    alt burn     " + alt_burn.
	print "    err          " + err.
	print "    err_min      " + err_min.
	print "    dv           " + round(dv,1).
	print "    dv rem       " + round(dv_rem,1).
	print "    accel max    " + accel_max.
	print "    est rem burn " + est_rem_burn.
	print "    throttle     " + round(th,3).
	print "    v mag 0      " + round(v0,1).
	print "    v mag        " + round(ship:velocity:orbit:mag,1).
	print "    burn dur     " + burn_duration.
	
	
	if		mvr_eta > 0 and
			mvr_eta < mvr_eta_0 and
			mode = 10 {

		print "burn in t-" + round(mvr_eta,1).

		set v0 to ship:velocity:orbit:mag.
	} else {
	
		set th to max(0, min(1, est_rem_burn / 10)).

		set err_min to min(err_min, err).
	
		if abs(err) > abs(err_min + 10) {
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
if mode = 0 {
	if eta:periapsis < eta:apoapsis {
		run warp("per",0).
	}
} else if mode = 1 {
	if eta:periapsis > eta:apoapsis {
		run warp("apo",0).
	}
}
}

//cleanup
unlock steering.



