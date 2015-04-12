
set get_stable_orbits_body to ship:body.
run get_stable_orbits.

set circle_altitude to 1.2 * get_stable_orbits_ret[0][0].
run circle.

