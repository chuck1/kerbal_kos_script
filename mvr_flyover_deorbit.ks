// PARAM mvr_flyover_deorbit_gc

run log("mvr_flyover_deorbit " + mvr_flyover_deorbit_gc).

set lines_add_line to "MVR FLYOVER DEORBIT" + ship:body + " " + mvr_flyover_deorbit_gc.
run lines_add.
set lines_indent to lines_indent + 1.

// useful vats
lock g to ship:body:mu / (ship:body:radius + altitude)^2.
lock accel_max to ship:maxthrust / ship:mass.
lock th_g to g / accel_max.
//

// calc bearing to latlong

lock s_r to ship:position - ship:body:position.

lock h to vcrs(
	s_r,
	ship:velocity:orbit - ship:body:velocity:orbit).

lock phase to
	vang(s_r, gc_r) *
	vdot(vcrs(s_r, gc_r), h) /
	abs(vdot(vcrs(s_r, gc_r), h)).

lock gc_r to mvr_flyover_deorbit_gc:position - ship:body:position.

lock gc_r_tangent to vxcl(h, gc_r).

lock inc_change to vang(gc_r, gc_r_tangent).

lock inc_sign to 
	vdot(vcrs(gc_r, gc_r_tangent), s_r).

lock dv_rem to 2 * ship:velocity:orbit:mag * sin(inc_change / 2).

set get_highest_peak_body to ship:body.
run get_highest_peak.

set mvr_flyover_deorbit_highest_peak to get_highest_peak_ret.

lock steering to R(
	retrograde:pitch,
	retrograde:yaw,
	ship:facing:roll).

run wait_orient.



// ====================================

// search for land position

set  t_l to time:seconds.
lock p_l to positionat(ship, t_l).
lock r_l to p_l - ship:body:position.

// horizontal distance to latlng at t_l
lock d_l to vxcl(r_l, p_l - mvr_flyover_deorbit_gc:position).

lock alt_l to r_l:mag - ship:body:radius.

// find time at which ship passes below highest peak



set d_l_min to 10000000000000.

until 0 {
	lock throttle to th_g.

	run lines_print_and_clear.
	print "MVR FLYOVER".
	print "=======================================".
	print "deorbit".
	print "    distance to lz " + round(d_l_min,0).

	set t_l to time:seconds.
	until 0 {
		//if alt_l < mvr_flyover_deorbit_gc:terrainheight + 2000 {
		if alt_l < mvr_flyover_deorbit_highest_peak {
			break.
		}
		set t_l to t_l + 1.
	}

	if d_l:mag > d_l_min {
		break.
	}

	set d_l_min to min(d_l_min, d_l:mag).
}
lock throttle to 0.

print "distance to target when passing".
print "through " + round(mvr_flyover_deorbit_highest_peak, 0) +
	" altitude is " + round(d_l_min, 0).

// could use time here to adjust for body rotation



// cleanup
set lines_indent to lines_indent - 1.




