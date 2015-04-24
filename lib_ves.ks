function ves_a_max {
	parameter ves.
	return ves:maxthrust / ves:mass.
}
function ves_burn_dur {
	parameter ves.
	parameter dv0.
	return abs(dv0) / ves_a_max(ves).
}
function ves_thrott_from_burn_dur {
	parameter ves.
	parameter dv0.
	return math_clamp(ves_burn_dur(ves,dv0) / 5, 0.01, 1).
}
function ves_thrott_from_a {
	parameter ves.
	parameter acc0.
	//print "ves_thrott_from_a " + ves + " " + acc0.
	return math_clamp(acc0 / ves_a_max(ves), 0, 1).
}
function ves_thrott_from_g {
	parameter ves.
	return math_clamp(ves_g(ves) / ves_a_max(ves), 0, 1).
}
function ves_g {
	parameter ves.
	return (ves:body:mu / ((ves:body:radius + ves:altitude)^2)).
}

function ves_normal {
	parameter ves.
	local vec is obt_h_for(ves).
	return vec:direction.
}
function ves_antinormal {
	parameter ves.
	local vec is -obt_h_for(ves).
	return vec:direction.
}
function ves_radialout {
	parameter ves.
	local vec is vcrs(obt_v_for(ves),obt_h_for(ves)).
	return vec:direction.
}
function ves_radialin {
	parameter ves.
	local vec is vcrs(obt_h_for(ves),obt_v_for(ves)).
	return vec:direction.
}

