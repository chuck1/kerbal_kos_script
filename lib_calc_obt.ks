
function get_stable_orbits {
	parameter body.
	
	//print "get_stable_orbits " + body.

	set ret to list().
	
	if body:atm:exists {
		set alt0 to body:atm:height.
	} else {
		set get_highest_peak_body to body.
		run get_highest_peak.
		
		set alt0 to get_highest_peak_ret.
	}
	
	set get_moons_body to body.
	run get_moons.
	
	set l to list().
	l:add(alt0).
	
	for m in get_moons_ret {
	
		set get_soi_body to m.
		run get_soi.
	
		l:add(m:periapsis - get_soi_ret).
		
		ret:add(l).
	
		set l to list().
		l:add(m:apoapsis + get_soi_ret).
	}
	
	set get_soi_body to body.
	run get_soi.
	
	l:add(get_soi_ret).
	
	ret:add(l).

	return ret.
}

function get_stable_orbits_2 {
	parameter body.

	//print "get_stable_orbits_2 " + body.

	// stable orbits with some room for error and extra room above body so that
	// low orbits dont have unstable apo/peri due to very low altitude
	
	local orbits is get_stable_orbits(body).
	
	set ret to list().
	
	// populate new list
	
	set get_stable_orbits_2_i to 0.
	
	until get_stable_orbits_2_i = orbits:length {
		set l to list().
	
		l:add(max(
			orbits[get_stable_orbits_2_i][0] * 1.1,
			body:radius * 3 / 40
			)).
		l:add(orbits[get_stable_orbits_2_i][1] * 0.9).
	
		ret:add(l).
	
		set get_stable_orbits_2_i to get_stable_orbits_2_i + 1.
	}
	return ret.
}	

function calc_obt_alt_low {
	parameter b.
	//print "calc_obt_alt_low " + b.
	local orbits is get_stable_orbits_2(b).
	return orbits[0][0].
}

function calc_obt_soe_circle {
	parameter b.
	parameter alt.
	
	//print "calc_obt_soe_circle " + b.

	local a is b:radius + alt.

	return (-1 * b:mu / (2 * a)).
}

function calc_obt_soe {
	parameter o.
	print "calc_obt_soe " + o.
	return (o:velocity:orbit:mag^2 / 2 - o:body:mu / (o:body:radius + o:altitude)).
}

function calc_obt_speed_at_altitude {
	parameter o.
	parameter altitude.
	return sqrt(2*(calc_obt_soe(o) + o:body:mu / (o:body:radius + altitude))).
}

print "loaded library lib_calc_obt".

