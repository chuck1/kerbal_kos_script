function calc_dv_inc_change {
	parameter i.
	return 2 * ship:velocity:orbit:mag * sin(i / 2).
}
