
// PARAMETER calc_latlong_to_vector_dest
// PARAMETER calc_latlong_to_vector_alt.

set calc_latlong_to_vector_r to calc_latlong_to_vector_alt + ship:body:radius.

set p1 to latitude.
set p2 to calc_latlong_to_vector_dest[0].

set l1 to longitude.
set l2 to calc_latlong_to_vector_dest[1].

set del_phi to calc_latlong_to_vector_dest[0]  - latitude.
set del_lam to calc_latlong_to_vector_dest[1] - longitude.



set s1 to sin(del_phi / 2).
set s2 to sin(del_lam / 2).

set a to s1^2 + cos(p1) * cos(p2) * s2^2.

set c to 2 * arctan2(sqrt(a), sqrt(1-a)).

set calc_latlong_to_vector_distance to
	calc_latlong_to_vector_r * c / 180 * CONSTANT():PI.

set calc_latlong_to_vector_delta_ta to
	360 * calc_latlong_to_vector_distance / (2 * CONSTANT():PI * calc_latlong_to_vector_r).

set calc_latlong_to_vector_vec_distance to
	2 * calc_latlong_to_vector_r * sin(calc_latlong_to_vector_delta_ta / 2).



set y to sin(del_lam) * cos(p2).

set x to cos(p1) * sin(p2) - sin(p1) * cos(p2) * cos(del_lam).

set calc_latlong_to_vector_brng to arctan2(y,x).

print "CALC LATLONG TO VECTOR".
print "----------------------".
print "    del phi               " + del_phi.
print "    del lam               " + del_lam.
print "    a                     " + a.
print "    c                     " + c.
print "    great circle distance " + calc_latlong_to_vector_distance.


















