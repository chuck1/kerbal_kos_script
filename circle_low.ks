set warp to 0.

util_log("circle_low").

local ret is get_stable_orbits_2(ship:body).

run circle(ret[0][0]).

