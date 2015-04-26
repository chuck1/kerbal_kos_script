function get_alt_safe {
	parameter bdy.
	local obts is get_stable_orbits(bdy).
	return obts[0][0].
}
function get_destination {
	parameter s.

	if s = "mun_arch" {
		return mun_arch.
	} else if s = "kerbin_vab" {
		return kerbin_vab.
	}
}
function get_aerobrake_alt {
	parameter b.
	
	if b = kerbin {
		return 35000.
	} else if get_aerobrake_alt_body = duna {
		return  13000.
	}

	return 0.
}
function get_capture_alt {
	parameter b.
	
	local get_aerobrake_alt_ret is get_aerobrake_alt(b).
	
	if get_aerobrake_alt_ret = 0 {
		set orbits to get_stable_orbits_2(b).
		
		return orbits[get_stable_orbits_ret:length - 1][1].
	}
	
	return get_aerobrake_alt_ret.
}
function get_highest_peak {
	parameter b.
	
	if b = kerbin {
		return 6767.
	} else if b = mun {
		return 7061.
	} else if b = duna {
		return 8264.
	} else if b = ike {
		// DONT KNOW!!!!!!!!!!!!!!!!!!!!!!!!!
		return 10000.
	}
	
	print neverset.
}

function get_highest_peak_here {
	return get_highest_peak(ship:body).
}
function get_moons {
	parameter b.
	
	local ret is list().
	
	if b = kerbin {
		ret:add(mun).
		ret:add(minmus).
	} else if b = duna {
		ret:add(ike).
	} else if b = jool {
		ret:add(laythe).
		ret:add(vall).
		ret:add(tylo).
		ret:add(bop).
		ret:add(pol).
	}

	return ret.
}
function get_soi {
	parameter b.
	
	if b = kerbin {
		return 84159286.
	} else if b = mun {
		return  2429559.
	} else if b = minmus {
		return  2247428.
	} else if b = duna {
		return 47921949.
	} else if b = ike {
		return  1049598.
	}
	
	print "no data for " + b.
	print neverset.
}
function get_alt_low {
	parameter bdy.
	local orbits is get_stable_orbits_2(bdy).
	return orbits[0][0].
}
function get_stable_orbits {
	parameter b.
	
	print "get_stable_orbits " + b.

	set ret to list().
	
	if b:atm:exists {
		set alt0 to b:atm:height.
	} else {
		set alt0 to get_highest_peak(b).
	}
	
	local ml is get_moons(b).
	
	local l is list().
	l:add(alt0).

	local m is 0.
	local i is 0.
	//for m in ml {
	until i = ml:length {
		set m to ml[i].
	
		local get_soi_ret to get_soi(m).
	
		l:add(m:periapsis - get_soi_ret).
		
		ret:add(l).
	
		set l to list().
		l:add(m:apoapsis + get_soi_ret).
		
		set i to i + 1.
	}
	
	l:add(get_soi(b)).
	
	ret:add(l).

	return ret.
}
function get_stable_orbits_2 {
	parameter b.

	print "get_stable_orbits_2 " + b.

	// stable orbits with some room for error and extra room above body so that
	// low orbits dont have unstable apo/peri due to very low altitude
	
	local orbits is get_stable_orbits(b).
	
	set ret to list().
	
	// populate new list
	
	local i is 0.
	
	until i = orbits:length {
		set l to list().
	
		l:add(max(
			orbits[i][0] * 1.1,
			b:radius * 3 / 40
			)).
		
		l:add(orbits[i][1] * 0.9).
	
		ret:add(l).
	
		set i to i + 1.
	}
	return ret.
}	
