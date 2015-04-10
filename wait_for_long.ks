print "WAIT FOR ANGLE ----------------------------------".
print "long:      " + wait_for_angle_angle.

lock norm to vcrs(
	ship:position - ship:body:position,
	ship:velocity:orbit - ship:body:velocity:orbit).



lock v0 to ship:position - ship:body:position.

lock d to vdot(norm, up:vector).

lock d_sign to d / abs(d).

lock diff_0 to d_sign * longitude - wait_for_angle_angle.

if diff_0 < 0 {
	lock diff to 360 + diff_0.
} else {
	lock diff to diff_0.
}


set warp_time_tspan to
	(diff / (360 - ship:obt:trueanomaly) * eta:periapsis - 30).

run warp_time.

lock e to abs((a - wait_for_angle_angle) / a).


wait until e < 0.01.


