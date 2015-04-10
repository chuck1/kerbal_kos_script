declare parameter prog_deltav_i.

set deltav_inc_return to 2 * ship:velocity:orbit:mag * sin(prog_deltav_i / 2).

