set warp to 0.

run log("circle_low").

set get_stable_orbits_2_body to ship:body.
run get_stable_orbits_2.

set circle_altitude to get_stable_orbits_2_ret[0][0].
run circle.

