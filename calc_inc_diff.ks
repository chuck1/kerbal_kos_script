declare parameter calc_inc_diff_target.

lock s_r to ship:position - ship:body:position.

lock h to vcrs(
	s_r,
	ship:velocity:orbit - ship:body:velocity:orbit).

lock phase to
	vang(s_r, gc_r) *
	vdot(vcrs(s_r, gc_r), h) /
	abs(vdot(vcrs(s_r, gc_r), h)).

lock gc_r to calc_inc_diff_target:position - ship:body:position.

lock gc_r_tangent to vxcl(h, gc_r).

set calc_inc_diff_ret to vang(gc_r, gc_r_tangent).



