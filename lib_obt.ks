
// ev = (v x h) / mu - r / |r|

// (ev + r / |r|) * mu = v x h

// -(ev + r / |r|) * mu = h x v

// v = ((-(ev + r / |r|) * mu) x h) / (h.h) + t * h

// i think t must be 0 so that v is in plane of ev and r


// a x b = c
// b = (c x a) / (a.a) + t a


// the following pseudo-struct shall define an orbit
// (without info about an orbitable's current position)
// obt_struc
//    h  - specific angular momentum vector
//    ev - eccentricity vector
function obt_struc_get_hv {
	parameter array. // this
	return array[0].
}
function obt_struc_get_ev {
	parameter array. // this
	return array[1].
}
function obt_struc_get_v_from_r {
	// get velocity vector based on position vector
	parameter array. // this
	parameter ves. // vessel
	parameter r. // position vector

	local h is obt_struc_get_hv(array).
	
	return vcrs((-(array[1] + r:normalized) * ves:body:mu), h) / vdot(h,h).
}
function obt_struc_get_a {
	parameter array. // this
	parameter bdy.   // need mu
	local hv is obt_struc_get_hv(array).
	local ev is obt_struc_get_ev(array).
	return vdot(hv,hv) / bdy:mu / (1-vdot(ev,ev)).
}
function obt_struc_get_rp {
	parameter array. // this
	parameter bdy.	
	local ev is obt_struc_get_ev(array).
	local  a is obt_struc_get_a(array, bdy).
	return a*(1-ev:mag).
}
function obt_struc_get_rvp {
	parameter array. // this
	parameter bdy.	
	local ev is obt_struc_get_ev(array).
	local rp is obt_struc_get_rp(array, bdy).
	return ev:normalized * rp.
}
function obt_struc_ctor_current_for {
	parameter ves.
	set ret to list().
	ret:add(obt_h_for(ves)).
	ret:add(obt_ev_for(ves)).
	return ret.
}
function obt_struc_ctor_circle {
	parameter bdy.
	parameter alt.
	parameter h_unit.
	local a is bdy:radius + alt.
	local h is sqrt(a * bdy:mu).
	local hv is h_unit:normalized * h.
	local ev is V(0,0,0).
	local ret is list().
	ret:add(hv).
	ret:add(ev).
	return ret.
}
// functions for calculating deltav
function obt_dv {
	// get deltav vector for
	parameter ves.
	parameter r. // common position vector (burn position)
	parameter os1. // obt_struc 1
	parameter os2. // obt_struc 2
	
	local v1 is obt_struc_get_v_from_r(os1, ves, r).
	local v2 is obt_struc_get_v_from_r(os2, ves, r).
	
	return v2 - v1.
}
function obt_dv_circle_per {
	// calculare dv to circularize at periapsis
	parameter ves.
	
	local os1 is obt_struc_ctor_current_for(ves).

	local os2 is obt_struc_ctor_circle(ves:body, periapsis, os1[0]).
	
	local r is obt_struc_get_rvp(os1, ves:body).

	return obt_dv(ship, r, os1, os2).
}
// functions for calculating aspects of current orbit for a vessel
function obt_r_for {
	// position vector of vessel
	parameter ves.
	return ves:position - ves:body:position.
}
function obt_v_for {
	// velocity vector of vessel
	parameter ves.
	return ves:velocity:orbit - ves:body:velocity:orbit.
}
function obt_v_tan_for {
	parameter ves.
	return vxcl(obt_r_for(ves), obt_v_for(ves)).
}
function obt_h_for {
	// angular momentum vector of vessel
	parameter ves.
	return vcrs(obt_r_for(ves), obt_v_for(ves)).
}
function obt_ev_for {
	// eccentricity vector of vessel
	parameter ves.
	return vcrs(obt_v_for(ves), obt_h_for(ves))/
		ves:body:mu - obt_r_for(ves):normalized.
}
// the following functions determine certain paramters based on
// certain hypothetical situations
function obt_v_from_ev_h_r {
	// get velocity vector given...
	parameter ves. // vessel
	parameter ev. // eccentricity vector
	parameter h. // mom vector
	parameter rv. // position vector
	return vcrs((-(ev + rv:normalized) * ves:body:mu), h) / vdot(h,h).
}



