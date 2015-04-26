

run lib_obt.ks.

local os1 is obt_struc_ctor_current_for(ship).

local os2 is obt_struc_ctor_circle(kerbin, ship:altitude, os1[0]).

print os1[0]:mag.
print os1[1]:mag.

print os2[0]:mag.
print os2[1]:mag.

local dv is obt_dv(ship, obt_r_for(ship), os1, os2).

print dv:mag.

local dv is obt_dv_circle_per(ship).

print dv:mag.


